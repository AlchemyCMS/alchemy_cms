module ActsAsFerret
        
  module ClassMethods

    # Disables ferret index updates for this model. When a block is given,
    # Ferret will be re-enabled again after executing the block.
    def disable_ferret
      aaf_configuration[:enabled] = false
      if block_given?
        yield
        enable_ferret
      end
    end

    def enable_ferret
      aaf_configuration[:enabled] = true
    end

    def ferret_enabled?
      aaf_configuration[:enabled]
    end

    # rebuild the index from all data stored for this model, and any other
    # model classes associated with the same index.
    # This is called automatically when no index exists yet.
    #
    def rebuild_index
      aaf_index.rebuild_index
    end

    # re-index a number records specified by the given ids. Use for large
    # indexing jobs i.e. after modifying a lot of records with Ferret disabled.
    # Please note that the state of Ferret (enabled or disabled at class or
    # record level) is not checked by this method, so if you need to do so
    # (e.g. because of a custom ferret_enabled? implementation), you have to do
    # so yourself.
    def bulk_index(*ids)
      options = Hash === ids.last ? ids.pop : {}
      ids = ids.first if ids.size == 1 && ids.first.is_a?(Enumerable)
      aaf_index.bulk_index(self.name, ids, options)
    end

    # true if our db and table appear to be suitable for the mysql fast batch
    # hack (see
    # http://weblog.jamisbuck.org/2007/4/6/faking-cursors-in-activerecord)
    def use_fast_batches?
      if connection.class.name =~ /Mysql/ && primary_key == 'id' && aaf_configuration[:mysql_fast_batches]
        logger.info "using mysql specific batched find :all. Turn off with  :mysql_fast_batches => false if you encounter problems (i.e. because of non-integer UUIDs in the id column)"
        true
      end
    end

    # Returns all records modified or created after the specified time.
    # Used by the rake rebuild task to find models that need to be updated in
    # the index after the rebuild finished because they changed while the
    # rebuild was running.
    # Override if your models don't stick to the created_at/updated_at
    # convention.
    def records_modified_since(time)
      condition = []
      %w(updated_at created_at).each do |col|
        condition << "#{col} >= ?" if column_names.include? col
      end
      if condition.empty?
        logger.warn "#{self.name}: Override records_modified_since(time) to keep the index up to date with records changed during rebuild."
        []
      else
        find :all, :conditions => [ condition.join(' AND '), *([time]*condition.size) ]
      end
    end

    # runs across all records yielding those to be indexed when the index is rebuilt
    def records_for_rebuild(batch_size = 1000)
      transaction do
        if use_fast_batches?
          offset = 0
          while (rows = find :all, :conditions => [ "#{table_name}.id > ?", offset ], :limit => batch_size).any?
            offset = rows.last.id
            yield rows, offset
          end
        else
          order = "#{primary_key} ASC" # fixes #212
          0.step(self.count, batch_size) do |offset|
            yield find( :all, :limit => batch_size, :offset => offset, :order => order ), offset
          end
        end
      end
    end

    # yields the records with the given ids, in batches of batch_size
    def records_for_bulk_index(ids, batch_size = 1000)
      transaction do
        offset = 0
        ids.each_slice(batch_size) do |id_slice|
          records = find( :all, :conditions => ["id in (?)", id_slice] )
          #yield records, offset
          yield find( :all, :conditions => ["id in (?)", id_slice] ), offset
          offset += batch_size
        end
      end
    end

    # Retrieve the index instance for this model class. This can either be a
    # LocalIndex, or a RemoteIndex instance.
    # 
    def aaf_index
      @index ||= ActsAsFerret::get_index(aaf_configuration[:name])
    end 
    
    # Finds instances by searching the Ferret index. Terms are ANDed by default, use 
    # OR between terms for ORed queries. Or specify +:or_default => true+ in the
    # +:ferret+ options hash of acts_as_ferret.
    #
    # You may either use the +offset+ and +limit+ options to implement your own
    # pagination logic, or use the +page+ and +per_page+ options to use the
    # built in pagination support which is compatible with will_paginate's view
    # helpers. If +page+ and +per_page+ are given, +offset+ and +limit+ will be
    # ignored.
    #
    # == options:
    # page::        page of search results to retrieve
    # per_page::    number of search results that are displayed per page
    # offset::      first hit to retrieve (useful for paging)
    # limit::       number of hits to retrieve, or :all to retrieve
    #               all results
    # lazy::        Array of field names whose contents should be read directly
    #               from the index. Those fields have to be marked 
    #               +:store => :yes+ in their field options. Give true to get all
    #               stored fields. Note that if you have a shared index, you have 
    #               to explicitly state the fields you want to fetch, true won't
    #               work here)
    #
    # +find_options+ is a hash passed on to active_record's find when
    # retrieving the data from db, useful to i.e. prefetch relationships with
    # :include or to specify additional filter criteria with :conditions (only string and array syntax supported).
    # You can also call find_with_ferret inside named or dynamic scopes, if you like the conditions hash syntax more.
    #
    # This method returns a +SearchResults+ instance, which really is an Array that has 
    # been decorated with a total_hits attribute holding the total number of hits.
    # Additionally, SearchResults is compatible with the pagination helper
    # methods of the will_paginate plugin.
    #
    # Please keep in mind that the number of results delivered might be less than 
    # +limit+ if you specify any active record conditions that further limit 
    # the result. Use +limit+ and +offset+ as AR find_options instead.
    # +page+ and +per_page+ are supposed to work regardless of any 
    # +conditions+ present in +find_options+.
    def find_with_ferret(q, options = {}, find_options = {})
      if respond_to?(:scope) && scope(:find, :conditions)
        find_options[:conditions] ||= '1=1' # treat external scope the same as if :conditions present (i.e. when it comes to counting results)
      end
      return ActsAsFerret::find q, self, options, find_options
    end 


    # Returns the total number of hits for the given query 
    #
    # Note that since we don't query the database here, this method won't deliver 
    # the expected results when used on an AR association.
    #
    def total_hits(q, options={})
      aaf_index.total_hits(q, options)
    end

    # Finds instance model name, ids and scores by contents. 
    # Useful e.g. if you want to search across models or do not want to fetch
    # all result records (yet).
    #
    # Options are the same as for find_with_ferret
    #
    # A block can be given too, it will be executed with every result:
    # find_ids_with_ferret(q, options) do |model, id, score|
    #    id_array << id
    #    scores_by_id[id] = score 
    # end
    # NOTE: in case a block is given, only the total_hits value will be returned
    # instead of the [total_hits, results] array!
    # 
    def find_ids_with_ferret(q, options = {}, &block)
      aaf_index.find_ids(q, options, &block)
    end

    
    protected

#    def find_records_lazy_or_not(q, options = {}, find_options = {})
#      if options[:lazy]
#        logger.warn "find_options #{find_options} are ignored because :lazy => true" unless find_options.empty?
#        lazy_find_by_contents q, options
#      else
#        ar_find_by_contents q, options, find_options
#      end
#    end
#
#    def ar_find_by_contents(q, options = {}, find_options = {})
#      result_ids = {}
#      total_hits = find_ids_with_ferret(q, options) do |model, id, score, data|
#        # stores ids, index and score of each hit for later ordering of
#        # results
#        result_ids[id] = [ result_ids.size + 1, score ]
#      end
#
#      result = ActsAsFerret::retrieve_records( { self.name => result_ids }, find_options )
#      
#      # count total_hits via sql when using conditions or when we're called
#      # from an ActiveRecord association.
#      if find_options[:conditions] or caller.find{ |call| call =~ %r{active_record/associations} }
#        # chances are the ferret result count is not our total_hits value, so
#        # we correct this here.
#        if options[:limit] != :all || options[:page] || options[:offset] || find_options[:limit] || find_options[:offset]
#          # our ferret result has been limited, so we need to re-run that
#          # search to get the full result set from ferret.
#          result_ids = {}
#          find_ids_with_ferret(q, options.update(:limit => :all, :offset => 0)) do |model, id, score, data|
#            result_ids[id] = [ result_ids.size + 1, score ]
#          end
#          # Now ask the database for the total size of the final result set.
#          total_hits = count_records( { self.name => result_ids }, find_options )
#        else
#          # what we got from the database is our full result set, so take
#          # it's size
#          total_hits = result.length
#        end
#      end
#
#      [ total_hits, result ]
#    end
#
#    def lazy_find_by_contents(q, options = {})
#      logger.debug "lazy_find_by_contents: #{q}"
#      result = []
#      rank   = 0
#      total_hits = find_ids_with_ferret(q, options) do |model, id, score, data|
#        logger.debug "model: #{model}, id: #{id}, data: #{data}"
#        result << FerretResult.new(model, id, score, rank += 1, data)
#      end
#      [ total_hits, result ]
#    end


    def model_find(model, id, find_options = {})
      model.constantize.find(id, find_options)
    end


#    def count_records(id_arrays, find_options = {})
#      count_options = find_options.dup
#      count_options.delete :limit
#      count_options.delete :offset
#      count = 0
#      id_arrays.each do |model, id_array|
#        next if id_array.empty?
#        model = model.constantize
#        # merge conditions
#        conditions = ActsAsFerret::combine_conditions([ "#{model.table_name}.#{model.primary_key} in (?)", id_array.keys ], 
#                                        find_options[:conditions])
#        opts = find_options.merge :conditions => conditions
#        opts.delete :limit; opts.delete :offset
#        count += model.count opts
#      end
#      count
#    end

  end
  
end

