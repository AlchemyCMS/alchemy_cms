module ActsAsFerret #:nodoc:

  # Base class for remote and local multi-indexes
  class MultiIndexBase
    include FerretFindMethods
    attr_accessor :logger

    def initialize(indexes, options = {})
      # ensure all models indexes exist
      @indexes = indexes
      indexes.each { |i| i.ensure_index_exists }
      default_fields = indexes.inject([]) do |fields, idx| 
        fields + [ idx.index_definition[:ferret][:default_field] ]
      end.flatten.uniq
      @options = {
        :default_field => default_fields
      }.update(options)
      @logger = IndexLogger.new(ActsAsFerret::logger, "multi: #{indexes.map(&:index_name).join(',')}")
    end

    def ar_find(query, options = {}, ar_options = {})
      limit = options.delete(:limit)
      offset = options.delete(:offset) || 0
      options[:limit] = :all
      total_hits, result = super query, options, ar_options  
      total_hits = result.size if ar_options[:conditions]
      # if limit && limit != :all
      #   result = result[offset..limit+offset-1]
      # end
      [total_hits, result]
    end
    
    def determine_stored_fields(options)
      return nil unless options.has_key?(:lazy)
      stored_fields = []
      @indexes.each do |index|
        stored_fields += index.determine_stored_fields(options)
      end
      return stored_fields.uniq
    end

    def shared?
      false
    end
      
  end
  
  # This class can be used to search multiple physical indexes at once.
  class MultiIndex < MultiIndexBase
    
    def extract_stored_fields(doc, stored_fields)
      ActsAsFerret::get_index_for(doc[:class_name]).extract_stored_fields(doc, stored_fields) unless stored_fields.blank?
    end

    def total_hits(q, options = {})
      search(q, options).total_hits
    end
    
    def search(query, options={})
      query = process_query(query, options)
      logger.debug "parsed query: #{query.to_s}"
      searcher.search(query, options)
    end

    def search_each(query, options = {}, &block)
      query = process_query(query, options)
      searcher.search_each(query, options, &block)
    end

    # checks if all our sub-searchers still are up to date
    def latest?
      #return false unless @reader
      # segfaults with 0.10.4 --> TODO report as bug @reader.latest?
      @reader and @reader.latest?
      #@sub_readers.each do |r| 
      #  return false unless r.latest? 
      #end
      #true
    end

    def searcher
      ensure_searcher
      @searcher
    end
    
    def doc(i)
      searcher[i]
    end
    alias :[] :doc
    
    def query_parser
      @query_parser ||= Ferret::QueryParser.new(@options)
    end
    
    def process_query(query, options = {})
      query = query_parser.parse(query) if query.is_a?(String)
      return query
    end

    def close
      @searcher.close if @searcher
      @reader.close if @reader
    end

    protected

      def ensure_searcher
        unless latest?
          @sub_readers = @indexes.map { |idx| 
            begin
              reader = Ferret::Index::IndexReader.new(idx.index_definition[:index_dir])
              logger.debug "sub-reader opened: #{reader}"
              reader
            rescue Exception
              raise "error opening reader on index for class #{clazz.inspect}: #{$!}"
            end
          }
          close
          @reader = Ferret::Index::IndexReader.new(@sub_readers)
          @searcher = Ferret::Search::Searcher.new(@reader)
        end
      end

  end # of class MultiIndex

end
