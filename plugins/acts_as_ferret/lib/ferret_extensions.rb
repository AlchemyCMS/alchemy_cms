module Ferret

  module Analysis
  
    # = PerFieldAnalyzer
    #
    # This PerFieldAnalyzer is a workaround to a memory leak in 
    # ferret 0.11.4. It does basically do the same as the original
    # Ferret::Analysis::PerFieldAnalyzer, but without the leak :)
    # 
    # http://ferret.davebalmain.com/api/classes/Ferret/Analysis/PerFieldAnalyzer.html
    #
    # Thanks to Ben from omdb.org for tracking this down and creating this
    # workaround.
    # You can read more about the issue there:
    # http://blog.omdb-beta.org/2007/7/29/tracking-down-a-memory-leak-in-ferret-0-11-4
    class PerFieldAnalyzer < ::Ferret::Analysis::Analyzer
      def initialize( default_analyzer = StandardAnalyzer.new )
        @analyzers = {}
        @default_analyzer = default_analyzer
      end
            
      def add_field( field, analyzer )
        @analyzers[field] = analyzer
      end
      alias []= add_field
                
      def token_stream(field, string)
        @analyzers.has_key?(field) ? @analyzers[field].token_stream(field, string) : 
          @default_analyzer.token_stream(field, string)
      end
    end
  end

  class Index::Index
    attr_accessor :batch_size, :logger

    def index_models(models)
      models.each { |model| index_model model }
      flush
      optimize
      close
      ActsAsFerret::close_multi_indexes
    end

    def index_model(model)
      bulk_indexer = ActsAsFerret::BulkIndexer.new(:batch_size => @batch_size, :logger => logger, 
                                                   :model => model, :index => self, :reindex => true)
      logger.info "reindexing model #{model.name}"

      model.records_for_rebuild(@batch_size) do |records, offset|
        bulk_indexer.index_records(records, offset)
      end
    end

    def bulk_index(model, ids, options = {})
      options.reverse_merge! :optimize => true
      orig_flush = @auto_flush
      @auto_flush = false
      bulk_indexer = ActsAsFerret::BulkIndexer.new(:batch_size => @batch_size, :logger => logger, 
                                                   :model => model, :index => self, :total => ids.size)
      model.records_for_bulk_index(ids, @batch_size) do |records, offset|
        logger.debug "#{model} bulk indexing #{records.size} at #{offset}"
        bulk_indexer.index_records(records, offset)
      end
      logger.info 'finishing bulk index...'
      flush
      if options[:optimize]
        logger.info 'optimizing...'
        optimize 
      end
      @auto_flush = orig_flush
    end
    

    # bulk-inserts a number of ferret documents.
    # The argument has to be an array of two-element arrays each holding the document data and the analyzer to 
    # use for this document (which may be nil).
    def update_batch(document_analyzer_pairs)
      ids = document_analyzer_pairs.collect {|da| da.first[@id_field] }
      @dir.synchronize do
        batch_delete(ids)
        ensure_writer_open()
        document_analyzer_pairs.each do |doc, analyzer|
          if analyzer
            old_analyzer = @writer.analyzer
            @writer.analyzer = analyzer
            @writer.add_document(doc)
            @writer.analyzer = old_analyzer
          else
            @writer.add_document(doc)
          end
        end
        flush()
      end      
    end
    
    # If +docs+ is a Hash or an Array then a batch delete will be performed.
    # If +docs+ is an Array then it will be considered an array of +id+'s. If
    # it is a Hash, then its keys will be used instead as the Array of
    # document +id+'s. If the +id+ is an Integers then it is considered a
    # Ferret document number and the corresponding document will be deleted.
    # If the +id+ is a String or a Symbol then the +id+ will be considered a
    # term and the documents that contain that term in the +:id_field+ will
    # be deleted.
    #
    # docs:: An Array of docs to be deleted, or a Hash (in which case the keys
    # are used)
    #
    # ripped from Ferret trunk.
    def batch_delete(docs)
      docs = docs.keys if docs.is_a?(Hash)
      raise ArgumentError, "must pass Array or Hash" unless docs.is_a? Array
      ids = []
      terms = []
      docs.each do |doc|
        case doc
        when String   then terms << doc
        when Symbol   then terms << doc.to_s
        when Integer  then ids << doc
        else
          raise ArgumentError, "Cannot delete for arg of type #{id.class}"
        end
      end
      if ids.size > 0
        ensure_reader_open
        ids.each {|id| @reader.delete(id)}
      end
      if terms.size > 0
        ensure_writer_open()
        terms.each { |t| @writer.delete(@id_field, t) }
        # TODO with Ferret trunk this would work:
        # @writer.delete(@id_field, terms)
      end
      return self
    end

    # search for the first document with +arg+ in the +id+ field and return it's internal document number. 
    # The +id+ field is either :id or whatever you set
    # :id_field parameter to when you create the Index object.
    def doc_number(id)
      @dir.synchronize do
        ensure_reader_open()
        term_doc_enum = @reader.term_docs_for(@id_field, id.to_s)
        return term_doc_enum.next? ? term_doc_enum.doc : nil
      end
    end
  end

  # add marshalling support to SortFields
  class Search::SortField
    def _dump(depth)
      to_s
    end

    def self._load(string)
      case string
        when /<DOC(_ID)?>!/         then Ferret::Search::SortField::DOC_ID_REV
        when /<DOC(_ID)?>/          then Ferret::Search::SortField::DOC_ID
        when '<SCORE>!'             then Ferret::Search::SortField::SCORE_REV
        when '<SCORE>'              then Ferret::Search::SortField::SCORE
        when /^(\w+):<(\w+)>(!)?$/  then new($1.to_sym, :type => $2.to_sym, :reverse => !$3.nil?)
        else raise "invalid value: #{string}"
      end
    end
  end

  # add marshalling support to Sort
  class Search::Sort
    def _dump(depth)
      to_s
    end

    def self._load(string)
      # we exclude the last <DOC> sorting as it is appended by new anyway
      if string =~ /^Sort\[(.*?)(<DOC>(!)?)?\]$/
        sort_fields = $1.split(',').map do |value| 
        value.strip!
          Ferret::Search::SortField._load value unless value.blank?
        end
        new sort_fields.compact
      else
        raise "invalid value: #{string}"
      end
    end
  end

end
