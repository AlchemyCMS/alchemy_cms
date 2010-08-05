# Copyright (c) 2006 Kasper Weibel Nielsen-Refs, Thomas Lockney, Jens Krämer
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'active_support'
require 'active_record'
require 'set'
require 'enumerator'
require 'ferret'

require 'ferret_find_methods'
require 'remote_functions'
require 'blank_slate'
require 'bulk_indexer'
require 'ferret_extensions'
require 'act_methods'
require 'search_results'
require 'class_methods'
require 'ferret_result'
require 'instance_methods'
require 'without_ar'

require 'multi_index'
require 'remote_multi_index'
require 'more_like_this'

require 'index'
require 'local_index'
require 'remote_index'

require 'ferret_server'

require 'rdig_adapter'

# The Rails ActiveRecord Ferret Mixin.
#
# This mixin adds full text search capabilities to any Rails model.
#
# The current version emerged from on the original acts_as_ferret plugin done by
# Kasper Weibel and a modified version done by Thomas Lockney, which  both can be 
# found on the Ferret Wiki: http://ferret.davebalmain.com/trac/wiki/FerretOnRails.
#
# basic usage:
# include the following in your model class (specifiying the fields you want to get indexed):
# acts_as_ferret :fields => [ :title, :description ]
#
# now you can use ModelClass.find_with_ferret(query) to find instances of your model
# whose indexed fields match a given query. All query terms are required by default, but 
# explicit OR queries are possible. This differs from the ferret default, but imho is the more
# often needed/expected behaviour (more query terms result in less results).
#
# Released under the MIT license.
#
# Authors: 
# Kasper Weibel Nielsen-Refs (original author)
# Jens Kraemer <jk@jkraemer.net> (active maintainer since 2006)
#
#
# == Global properties
#
# raise_drb_errors:: Set this to true if you want aaf to raise Exceptions
#                    in case the DRb server cannot be reached (in other word - behave like
#                    versions up to 0.4.3). Defaults to false so DRb exceptions
#                    are logged but not raised. Be sure to set up some
#                    monitoring so you still detect when your DRb server died for
#                    whatever reason.
#
# remote:: Set this to false to force acts_as_ferret into local (non-DRb) mode even if
#          config/ferret_server.yml contains a section for the current RAILS_ENV
#          Usually you won't need to touch this option - just configure DRb for
#          production mode in ferret_server.yml.
#
module ActsAsFerret

  class ActsAsFerretError < StandardError; end
  class IndexNotDefined < ActsAsFerretError; end
  class IndexAlreadyDefined < ActsAsFerretError; end

  # global Hash containing all multi indexes created by all classes using the plugin
  # key is the concatenation of alphabetically sorted names of the classes the
  # searcher searches.
  @@multi_indexes = Hash.new
  def self.multi_indexes; @@multi_indexes end

  # global Hash containing the ferret indexes of all classes using the plugin
  # key is the index name.
  @@ferret_indexes = Hash.new
  def self.ferret_indexes; @@ferret_indexes end

  # mapping from class name to index name
  @@index_using_classes = {}
  def self.index_using_classes; @@index_using_classes end

  @@logger = Logger.new "#{RAILS_ROOT}/log/acts_as_ferret.log"
  @@logger.level = ActiveRecord::Base.logger.level rescue Logger::DEBUG
  mattr_accessor :logger

    
  # Default ferret configuration for index fields
  DEFAULT_FIELD_OPTIONS = {
    :store       => :no, 
    :highlight   => :yes, 
    :index       => :yes, 
    :term_vector => :with_positions_offsets,
    :boost       => 1.0
  }

  @@raise_drb_errors = false
  mattr_writer :raise_drb_errors
  def self.raise_drb_errors?; @@raise_drb_errors end
  
  @@remote = nil
  mattr_accessor :remote
  def self.remote?
    if @@remote.nil?
      if ENV["FERRET_USE_LOCAL_INDEX"] || ActsAsFerret::Remote::Server.running
        @@remote = false
      else
        @@remote = ActsAsFerret::Remote::Config.new.uri rescue false
      end
      if @@remote
        logger.info "Will use remote index server which should be available at #{@@remote}"
      else
        logger.info "Will use local index."
      end
    end
    @@remote
  end
  remote?


  # Globally declares an index.
  #
  # This method is also used to implicitly declare an index when you use the
  # acts_as_ferret call in your class. Returns the created index instance.
  #
  # === Options are:
  #
  # +models+:: Hash of model classes and their per-class option hashes which should
  #            use this index. Any models mentioned here will automatically use
  #            the index, there is no need to explicitly call +acts_as_ferret+ in the
  #            model class definition.
  def self.define_index(name, options = {})
    name = name.to_sym
    pending_classes = nil
    if ferret_indexes.has_key?(name)
      # seems models have been already loaded. remove that index for now,
      # re-register any already loaded classes later on.
      idx = get_index(name)
      pending_classes = idx.index_definition[:registered_models]
      pending_classes_configs = idx.registered_models_config
      idx.close
      ferret_indexes.delete(name)
    end

    index_definition = {
      :index_dir => "#{ActsAsFerret::index_dir}/#{name}",
      :name => name,
      :single_index => false,
      :reindex_batch_size => 1000,
      :ferret => {},
      :ferret_fields => {},             # list of indexed fields that will be filled later
      :enabled => true,                 # used for class-wide disabling of Ferret
      :mysql_fast_batches => true,      # turn off to disable the faster, id based batching mechanism for MySQL
      :raise_drb_errors => false        # handle DRb connection errors by default
    }.update( options )

    index_definition[:registered_models] = []
    
    # build ferret configuration
    index_definition[:ferret] = {
      :or_default          => false, 
      :handle_parse_errors => true,
      :default_field       => nil,              # will be set later on
      #:max_clauses => 512,
      #:analyzer => Ferret::Analysis::StandardAnalyzer.new,
      # :wild_card_downcase => true
    }.update( options[:ferret] || {} )

    index_definition[:user_default_field] = index_definition[:ferret][:default_field]

    unless remote?
      ActsAsFerret::ensure_directory index_definition[:index_dir] 
      index_definition[:index_base_dir] = index_definition[:index_dir]
      index_definition[:index_dir] = find_last_index_version(index_definition[:index_dir])
      logger.debug "using index in #{index_definition[:index_dir]}"
    end
    
    # these properties are somewhat vital to the plugin and shouldn't
    # be overwritten by the user:
    index_definition[:ferret].update(
      :key               => :key,
      :path              => index_definition[:index_dir],
      :auto_flush        => true, # slower but more secure in terms of locking problems TODO disable when running in drb mode?
      :create_if_missing => true
    )

    # field config
    index_definition[:ferret_fields] = build_field_config( options[:fields] )
    index_definition[:ferret_fields].update build_field_config( options[:additional_fields] )

    idx = ferret_indexes[name] = create_index_instance( index_definition )

    # re-register early loaded classes
    if pending_classes
      pending_classes.each { |clazz| idx.register_class clazz, { :force_re_registration => true }.merge(pending_classes_configs[clazz]) }
    end

    if models = options[:models]
      models.each do |clazz, config|
        clazz.send :include, ActsAsFerret::WithoutAR unless clazz.respond_to?(:acts_as_ferret)
        clazz.acts_as_ferret config.merge(:index => name)
      end
    end

    return idx
  end
 
  # called internally by the acts_as_ferret method
  #
  # returns the index
  def self.register_class_with_index(clazz, index_name, options = {})
    index_name = index_name.to_sym
    @@index_using_classes[clazz.name] = index_name
    unless index = ferret_indexes[index_name]
      # index definition on the fly
      # default to all attributes of this class
      options[:fields] ||= clazz.new.attributes.keys.map { |k| k.to_sym }
      index = define_index index_name, options
    end
    index.register_class(clazz, options)
    return index
  end

  def self.load_config
    # using require_dependency to make the reloading in dev mode work.
    require_dependency "#{RAILS_ROOT}/config/aaf.rb"
    ActsAsFerret::logger.info "loaded configuration file aaf.rb"
  rescue LoadError
  ensure
    @aaf_config_loaded = true
  end

  # returns the index with the given name.
  def self.get_index(name)
    name = name.to_sym rescue nil
    unless ferret_indexes.has_key?(name)
      if @aaf_config_loaded
        raise IndexNotDefined.new(name.to_s)
      else
        load_config and return get_index name
      end
    end
    ferret_indexes[name]
  end

  # count hits for a query
  def self.total_hits(query, models_or_index_name, options = {})
    options = add_models_to_options_if_necessary options, models_or_index_name
    find_index(models_or_index_name).total_hits query, options
  end

  # find ids of records
  def self.find_ids(query, models_or_index_name, options = {}, &block)
    options = add_models_to_options_if_necessary options, models_or_index_name
    find_index(models_or_index_name).find_ids query, options, &block
  end
  
  # returns an index instance suitable for searching/updating the named index. Will 
  # return a read only MultiIndex when multiple model classes are given that do not
  # share the same physical index.
  def self.find_index(models_or_index_name)
    case models_or_index_name
    when Symbol
      get_index models_or_index_name
    when String
      get_index models_or_index_name.to_sym
    else
      get_index_for models_or_index_name
    end
  end

  # models_or_index_name may be an index name as declared in config/aaf.rb,
  # a single class or an array of classes to limit search to these classes.
  def self.find(query, models_or_index_name, options = {}, ar_options = {})
    models = case models_or_index_name
    when Array
      models_or_index_name
    when Class
      [ models_or_index_name ]
    else
      nil
    end
    index = find_index(models_or_index_name)
    multi = (MultiIndexBase === index or index.shared?)
    unless options[:per_page]
      options[:limit] ||= ar_options.delete :limit
      options[:offset] ||= ar_options.delete :offset
    end
    if options[:limit] || options[:per_page]
      # need pagination
      options[:page] = if options[:per_page]
        options[:page] ? options[:page].to_i : 1
      else
        nil
      end
      limit = options[:limit] || options[:per_page]
      offset = options[:offset] || (options[:page] ? (options[:page] - 1) * limit : 0)
      options.delete :offset
      options[:limit] = :all
      
      if multi or ((ar_options[:conditions] || ar_options[:order]) && options[:sort])
        # do pagination as the last step after everything has been fetched
        options[:late_pagination] = { :limit => limit, :offset => offset }
      elsif ar_options[:conditions] or ar_options[:order]
        # late limiting in AR call
        unless limit == :all
          ar_options[:limit] = limit
          ar_options[:offset] = offset
        end
      else
        options[:limit] = limit
        options[:offset] = offset
      end
    end
    ActsAsFerret::logger.debug "options: #{options.inspect}\nar_options: #{ar_options.inspect}"
    total_hits, result = index.find_records query, options.merge(:models => models), ar_options
    ActsAsFerret::logger.debug "Query: #{query}\ntotal hits: #{total_hits}, results delivered: #{result.size}"
    SearchResults.new(result, total_hits, options[:page], options[:per_page])
  end

  def self.filter_include_list_for_model(model, include_options)
    filtered_include_options = []
    include_options = Array(include_options)
    include_options.each do |include_option|
      filtered_include_options << include_option if model.reflections.has_key?(include_option.is_a?(Hash) ? include_option.keys[0].to_sym : include_option.to_sym)
    end
    return filtered_include_options
  end
  
  # returns the index used by the given class.
  #
  # If multiple classes are given, either the single index shared by these
  # classes, or a multi index (to be used for search only) across the indexes
  # of all models, is returned.
  def self.get_index_for(*classes)
    classes.flatten!
    raise ArgumentError.new("no class specified") unless classes.any?
    classes.map!(&:constantize) unless Class === classes.first
    logger.debug "index_for #{classes.inspect}"
    index = if classes.size > 1
      indexes = classes.map { |c| get_index_for c }.uniq
      indexes.size > 1 ? multi_index(indexes) : indexes.first
    else
      clazz = classes.first
      clazz = clazz.superclass while clazz && !@@index_using_classes.has_key?(clazz.name)
      get_index @@index_using_classes[clazz.name]
    end
    raise IndexNotDefined.new("no index found for class: #{classes.map(&:name).join(',')}") if index.nil?
    return index
  end


  # creates a new Index instance.
  def self.create_index_instance(definition)
    (remote? ? RemoteIndex : LocalIndex).new(definition)
  end

  def self.rebuild_index(name)
    get_index(name).rebuild_index
  end

  def self.change_index_dir(name, new_dir)
    get_index(name).change_index_dir new_dir
  end

  # find the most recent version of an index
  def self.find_last_index_version(basedir)
    # check for versioned index
    versions = Dir.entries(basedir).select do |f| 
      dir = File.join(basedir, f)
      File.directory?(dir) && File.file?(File.join(dir, 'segments')) && f =~ /^\d+(_\d+)?$/
    end
    if versions.any?
      # select latest version
      versions.sort!
      File.join basedir, versions.last
    else
      basedir
    end
  end

  # returns a MultiIndex instance operating on a MultiReader
  def self.multi_index(indexes)
    index_names = indexes.dup
    index_names = index_names.map(&:to_s) if Symbol === index_names.first
    if String === index_names.first
      indexes = index_names.map{ |name| get_index name }
    else
      index_names = index_names.map{ |i| i.index_name.to_s }
    end
    key = index_names.sort.join(",")
    ActsAsFerret::multi_indexes[key] ||= (remote? ? ActsAsFerret::RemoteMultiIndex : ActsAsFerret::MultiIndex).new(indexes)
  end

  # check for per-model conditions and return these if provided
  def self.conditions_for_model(model, conditions = {})
    if Hash === conditions
      key = model.name.underscore.to_sym
      conditions = conditions[key]
    end
    return conditions
  end

  # retrieves search result records from a data structure like this:
  # { 'Model1' => { '1' => [ rank, score ], '2' => [ rank, score ] }
  #
  # TODO: in case of STI AR will filter out hits from other 
  # classes for us, but this
  # will lead to less results retrieved --> scoping of ferret query
  # to self.class is still needed.
  # from the ferret ML (thanks Curtis Hatter)
  # > I created a method in my base STI class so I can scope my query. For scoping
  # > I used something like the following line:
  # > 
  # > query << " role:#{self.class.eql?(Contents) '*' : self.class}"
  # > 
  # > Though you could make it more generic by simply asking
  # > "self.descends_from_active_record?" which is how rails decides if it should
  # > scope your "find" query for STI models. You can check out "base.rb" in
  # > activerecord to see that.
  # but maybe better do the scoping in find_ids_with_ferret...
  def self.retrieve_records(id_arrays, find_options = {})
    result = []
    # get objects for each model
    id_arrays.each do |model, id_array|
      next if id_array.empty?
      model_class = model.constantize

      # merge conditions
      conditions = conditions_for_model model_class, find_options[:conditions]
      conditions = combine_conditions([ "#{model_class.table_name}.#{model_class.primary_key} in (?)", 
                                        id_array.keys ], 
                                      conditions)

      # check for include association that might only exist on some models in case of multi_search
      filtered_include_options = nil
      if include_options = find_options[:include]
        filtered_include_options = filter_include_list_for_model(model_class, include_options)
      end

      # fetch
      tmp_result = model_class.find(:all, find_options.merge(:conditions => conditions, 
                                                             :include    => filtered_include_options))

      # set scores and rank
      tmp_result.each do |record|
        record.ferret_rank, record.ferret_score = id_array[record.id.to_s]
      end
      # merge with result array
      result += tmp_result
    end
    
    # order results as they were found by ferret, unless an AR :order
    # option was given
    result.sort! { |a, b| a.ferret_rank <=> b.ferret_rank } unless find_options[:order]
    return result
  end
  
  # combine our conditions with those given by user, if any
  def self.combine_conditions(conditions, additional_conditions = [])
    returning conditions do
      if additional_conditions && additional_conditions.any?
        cust_opts = (Array === additional_conditions) ? additional_conditions.dup : [ additional_conditions ]
        logger.debug "cust_opts: #{cust_opts.inspect}"
        conditions.first << " and " << cust_opts.shift
        conditions.concat(cust_opts)
      end
    end
  end

  def self.build_field_config(fields)
    field_config = {}
    case fields
    when Array
      fields.each { |name| field_config[name] = field_config_for name }
    when Hash
      fields.each { |name, options| field_config[name] = field_config_for name, options }
    else raise InvalidArgumentError.new(":fields option must be Hash or Array")
    end if fields
    return field_config
  end

  def self.ensure_directory(dir)
    FileUtils.mkdir_p dir unless (File.directory?(dir) || File.symlink?(dir))
  end

  
  # make sure the default index base dir exists. by default, all indexes are created
  # under RAILS_ROOT/index/RAILS_ENV
  def self.init_index_basedir
    index_base = "#{RAILS_ROOT}/index"
    @@index_dir = "#{index_base}/#{RAILS_ENV}"
  end
  
  mattr_accessor :index_dir
  init_index_basedir
  
  def self.append_features(base)
    super
    base.extend(ClassMethods)
  end
  
  # builds a FieldInfos instance for creation of an index
  def self.field_infos(index_definition)
    # default attributes for fields
    fi = Ferret::Index::FieldInfos.new(:store => :no, 
                                        :index => :yes, 
                                        :term_vector => :no,
                                        :boost => 1.0)
    # unique key composed of classname and id
    fi.add_field(:key, :store => :no, :index => :untokenized)
    # primary key
    fi.add_field(:id, :store => :yes, :index => :untokenized) 
    # class_name
    fi.add_field(:class_name, :store => :yes, :index => :untokenized)

    # other fields
    index_definition[:ferret_fields].each_pair do |field, options|
      options = options.dup
      options.delete :via
      options.delete :boost if options[:boost].is_a?(Symbol) # dynamic boost
      fi.add_field(field, options)
    end
    return fi
  end

  def self.close_multi_indexes
    # close combined index readers, just in case
    # this seems to fix a strange test failure that seems to relate to a
    # multi_index looking at an old version of the content_base index.
    multi_indexes.each_pair do |key, index|
      # puts "#{key} -- #{self.name}"
      # TODO only close those where necessary (watch inheritance, where
      # self.name is base class of a class where key is made from)
      index.close #if key =~ /#{self.name}/
    end
    multi_indexes.clear
  end

  protected

  def self.add_models_to_options_if_necessary(options, models_or_index_name)
    return options if String === models_or_index_name or Symbol === models_or_index_name
    options.merge(:models => models_or_index_name)
  end

  def self.field_config_for(fieldname, options = {})
    config = DEFAULT_FIELD_OPTIONS.merge options
    config[:via] ||= fieldname
    config[:term_vector] = :no if config[:index] == :no
    return config
  end

end

# include acts_as_ferret method into ActiveRecord::Base
ActiveRecord::Base.extend ActsAsFerret::ActMethods

