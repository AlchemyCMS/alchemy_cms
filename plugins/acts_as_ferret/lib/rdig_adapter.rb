begin
  require 'rdig'
rescue LoadError
end
require 'digest/md5'

module ActsAsFerret

  # The RdigAdapter is automatically included into your model if you specify
  # the +:rdig+ options hash in your call to acts_as_ferret. It overrides
  # several methods declared by aaf to retrieve documents with the help of
  # RDig's http crawler when you call rebuild_index.
  module RdigAdapter

    if defined?(RDig)

      def self.included(target)
        target.extend ClassMethods
        target.send :include, InstanceMethods
        target.alias_method_chain :ferret_key, :md5
      end

      # Indexer class to replace RDig's original indexer
      class Indexer
        include MonitorMixin
        def initialize(batch_size, model_class, &block)
          @batch_size = batch_size
          @model_class = model_class
          @documents = []
          @offset = 0
          @block = block
          super()
        end

        def add(doc)
          synchronize do
            @documents << @model_class.new(doc.uri.to_s, doc)
            process_batch if @documents.size >= @batch_size
          end
        end
        alias << add

        def close
          synchronize do
            process_batch
          end
        end

        protected
        def process_batch
          ActsAsFerret::logger.info "RdigAdapter::Indexer#process_batch: #{@documents.size} docs in queue, offset #{@offset}"
          @block.call @documents, @offset
          @offset += @documents.size
          @documents = []
        end
      end
      
      module ClassMethods
        # overriding aaf to return the documents fetched via RDig
        def records_for_rebuild(batch_size = 1000, &block)
          indexer = Indexer.new(batch_size, self, &block)
          configure_rdig do
            crawler = RDig::Crawler.new RDig.configuration, ActsAsFerret::logger
            crawler.instance_variable_set '@indexer', indexer
            ActsAsFerret::logger.debug "now crawling..."
            crawler.crawl
          end
        rescue => e
          ActsAsFerret::logger.error e
          ActsAsFerret::logger.debug e.backtrace.join("\n")
        ensure
          indexer.close if indexer
        end

        # overriding aaf to skip reindexing records changed during the rebuild
        # when rebuilding with the rake task
        def records_modified_since(time)
          []
        end

        # unfortunately need to modify global RDig.configuration because it's
        # used everywhere in RDig
        def configure_rdig
          # back up original config
          old_logger = RDig.logger
          old_cfg = RDig.configuration.dup
          RDig.logger = ActsAsFerret.logger
          rdig_configuration[:crawler].each { |k,v| RDig.configuration.crawler.send :"#{k}=", v } if rdig_configuration[:crawler]
          if ce_config = rdig_configuration[:content_extraction]
            RDig.configuration.content_extraction = OpenStruct.new( :hpricot => OpenStruct.new( ce_config ) )
          end
          yield
        ensure
          # restore original config
          RDig.configuration.crawler = old_cfg.crawler
          RDig.configuration.content_extraction = old_cfg.content_extraction
          RDig.logger = old_logger
        end

        # overriding aaf to enforce loading page title and content from the
        # ferret index
        def find_with_ferret(q, options = {}, find_options = {})
          options[:lazy] = true
          super
        end

        def find_for_id(id)
          new id
        end
      end

      module InstanceMethods
        def initialize(uri, rdig_document = nil)
          @id = uri
          @rdig_document = rdig_document
        end

        # Title of the document.
        # Use the +:title_tag_selector+ option to declare the hpricot expression
        # that should be used for selecting the content for this field.
        def title
          @rdig_document.title
        end

        # Content of the document.
        # Use the +:content_tag_selector+ option to declare the hpricot expression
        # that should be used for selecting the content for this field.
        def content
          @rdig_document.body
        end

        # Url of this document.
        def id
          @id
        end

        def ferret_key_with_md5
          Digest::MD5.hexdigest(ferret_key_without_md5)
        end
        
        def to_s
          "Page at #{id}, title: #{title}"
        end
      end
    end
  end
  
end
