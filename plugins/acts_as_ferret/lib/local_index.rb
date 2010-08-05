module ActsAsFerret
  class LocalIndex < AbstractIndex
    include MoreLikeThis::IndexMethods

    def initialize(index_name)
      super
      ensure_index_exists
    end

    def reopen!
      logger.debug "reopening index at #{index_definition[:ferret][:path]}"
      close
      ferret_index
    end

    # The 'real' Ferret Index instance
    def ferret_index
      ensure_index_exists
      returning @ferret_index ||= Ferret::Index::Index.new(index_definition[:ferret]) do
        @ferret_index.batch_size = index_definition[:reindex_batch_size]
        @ferret_index.logger = logger
      end
    end

    # Checks for the presence of a segments file in the index directory
    # Rebuilds the index if none exists.
    def ensure_index_exists
      #logger.debug "LocalIndex: ensure_index_exists at #{index_definition[:index_dir]}"
      unless File.file? "#{index_definition[:index_dir]}/segments"
        ActsAsFerret::ensure_directory(index_definition[:index_dir])
        rebuild_index 
      end
    end

    # Closes the underlying index instance
    def close
      @ferret_index.close if @ferret_index
    rescue StandardError 
      # is raised when index already closed
    ensure
      @ferret_index = nil
    end

    # rebuilds the index from all records of the model classes associated with this index
    def rebuild_index
      models = index_definition[:registered_models]
      logger.debug "rebuild index with models: #{models.inspect}"
      close
      index = Ferret::Index::Index.new(index_definition[:ferret].dup.update(:auto_flush  => false, 
                                                                            :field_infos => ActsAsFerret::field_infos(index_definition),
                                                                            :create      => true))
      index.batch_size = index_definition[:reindex_batch_size]
      index.logger = logger
      index.index_models models
      reopen!
    end

    def bulk_index(class_name, ids, options)
      ferret_index.bulk_index(class_name.constantize, ids, options)
    end

    # Parses the given query string into a Ferret Query object.
    def process_query(query, options = {})
      return query unless String === query
      ferret_index.synchronize do
        if options[:analyzer]
          # use per-query analyzer if present
          qp = Ferret::QueryParser.new ferret_index.instance_variable_get('@options').merge(options)
          reader = ferret_index.reader
          qp.fields =
              reader.fields unless options[:all_fields] || options[:fields]
          qp.tokenized_fields =
              reader.tokenized_fields unless options[:tokenized_fields]
          return qp.parse query
        else
          # work around ferret bug in #process_query (doesn't ensure the
          # reader is open)
          ferret_index.send(:ensure_reader_open)
          return ferret_index.process_query(query)
        end
      end
    end

    # Total number of hits for the given query. 
    def total_hits(query, options = {})
      ferret_index.search(process_query(query, options), options).total_hits
    end

    def searcher
      ferret_index
    end


    ######################################
    # methods working on a single record
    # called from instance_methods, here to simplify interfacing with the
    # remote ferret server
    # TODO having to pass id and class_name around like this isn't nice
    ######################################

    # add record to index
    # record may be the full AR object, a Ferret document instance or a Hash
    def add(record, analyzer = nil)
      unless Hash === record || Ferret::Document === record
        analyzer = record.ferret_analyzer
        record = record.to_doc 
      end
      ferret_index.add_document(record, analyzer)
    end
    alias << add

    # delete record from index
    def remove(key)
      ferret_index.delete key
    end

    # highlight search terms for the record with the given id.
    def highlight(key, query, options = {})
      logger.debug("highlight: #{key} query: #{query}")
      options.reverse_merge! :num_excerpts => 2, :pre_tag => '<em>', :post_tag => '</em>'
      highlights = []
      ferret_index.synchronize do
        doc_num = document_number(key)

        if options[:field]
          highlights << ferret_index.highlight(query, doc_num, options)
        else
          query = process_query(query) # process only once
          index_definition[:ferret_fields].each_pair do |field, config|
            next if config[:store] == :no || config[:highlight] == :no
            options[:field] = field
            highlights << ferret_index.highlight(query, doc_num, options)
          end
        end
      end
      return highlights.compact.flatten[0..options[:num_excerpts]-1]
    end

    # retrieves the ferret document number of the record with the given key.
    def document_number(key)
      docnum = ferret_index.doc_number(key)
      # hits = ferret_index.search query_for_record(key)
      # return hits.hits.first.doc if hits.total_hits == 1
      raise "cannot determine document number for record #{key}" if docnum.nil?
      docnum
    end

    # build a ferret query matching only the record with the given id
    # the class name only needs to be given in case of a shared index configuration
    def query_for_record(key)
      return Ferret::Search::TermQuery.new(:key, key.to_s)
      # if shared?
      #   raise InvalidArgumentError.new("shared index needs class_name argument") if class_name.nil?
      #   returning bq = Ferret::Search::BooleanQuery.new do
      #     bq.add_query(Ferret::Search::TermQuery.new(:id,         id.to_s),    :must)
      #     bq.add_query(Ferret::Search::TermQuery.new(:class_name, class_name), :must)
      #   end
      # else
      #   Ferret::Search::TermQuery.new(:id, id.to_s)
      # end
    end


    # retrieves stored fields from index definition in case the fields to retrieve 
    # haven't been specified with the :lazy option
    def determine_stored_fields(options = {})
      stored_fields = options[:lazy]
      if stored_fields && !(Array === stored_fields)
        stored_fields = index_definition[:ferret_fields].select { |field, config| config[:store] == :yes }.map(&:first)
      end
      logger.debug "stored_fields: #{stored_fields.inspect}"
      return stored_fields
    end

    # loads data for fields declared as :lazy from the Ferret document
    def extract_stored_fields(doc, stored_fields) 
      data = {} 
      unless stored_fields.nil?
        logger.debug "extracting stored fields #{stored_fields.inspect} from document #{doc[:class_name]} / #{doc[:id]}"
        fields = index_definition[:ferret_fields] 
        stored_fields.each do |field|
          if field_cfg = fields[field]
            data[field_cfg[:via]] = doc[field]
          end
        end
        logger.debug "done: #{data.inspect}"
      end
      return data 
    end

    protected

    # returns a MultiIndex instance operating on a MultiReader
    #def multi_index(model_classes)
    #  model_classes.map!(&:constantize) if String === model_classes.first
    #  model_classes.sort! { |a, b| a.name <=> b.name }
    #  key = model_classes.inject("") { |s, clazz| s + clazz.name }
    #  multi_config = index_definition[:ferret].dup
    #  multi_config.delete :default_field  # we don't want the default field list of *this* class for multi_searching
    #  ActsAsFerret::multi_indexes[key] ||= MultiIndex.new(model_classes, multi_config)
    #end
 
  end

end
