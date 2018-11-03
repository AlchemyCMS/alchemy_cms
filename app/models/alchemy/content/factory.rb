# frozen_string_literal: true

module Alchemy
  # Holds everything concerning the building and creating of contents and the related essence object.
  #
  module Content::Factory
    extend ActiveSupport::Concern

    module ClassMethods
      SKIPPED_ATTRIBUTES_ON_COPY = %w(position created_at updated_at creator_id updater_id id)

      # Builds a new content as descriped in the elements.yml file.
      #
      # @param [Hash]
      #   The content definition used for finding the content in +elements.yml+ file
      #
      def new(attributes = {})
        element = attributes[:element] || Element.find_by(id: attributes[:element_id])
        return super if attributes.empty? || element.nil?

        definition = element.content_definition_for(attributes[:name])
        if definition.blank?
          raise ContentDefinitionError, "No definition found in elements.yml for #{attributes.inspect} and #{element.inspect}"
        end
        super(name: definition['name'], element_id: element.id)
      end
      alias_method :build, :new
      deprecate build: :new, deprecator: Alchemy::Deprecation

      # Creates a new content from elements definition in the +elements.yml+ file.
      #
      # 1. It builds the content
      # 2. It creates the essence record (content object gets saved)
      #
      # @return [Alchemy::Content]
      #
      def create(*args)
        attributes = args.last || {}
        if args.length > 1
          Alchemy::Deprecation.warn 'Passing an element as first argument to Alchemy::Content.create is deprecated! Pass an attribute hash with element inside instead.'
          element = args.first
        else
          element = attributes[:element]
        end
        new(attributes.merge(element: element)).tap do |content|
          content.create_essence!(attributes[:essence_type])
        end
      end
      alias_method :create_from_scratch, :create
      deprecate create_from_scratch: :create, deprecator: Alchemy::Deprecation

      # Creates a copy of source and also copies the associated essence.
      #
      # You can pass a differences hash to update the attributes of the copy.
      #
      # === Example
      #
      #   @copy = Alchemy::Content.copy(@content, {element_id: 3})
      #   @copy.element_id # => 3
      #
      def copy(source, differences = {})
        new_content = Content.new(
          source.attributes.
            except(*SKIPPED_ATTRIBUTES_ON_COPY).
            merge(differences.with_indifferent_access)
        )
        new_essence = source.essence.class.create!(
          source.essence.attributes.
            except(*SKIPPED_ATTRIBUTES_ON_COPY)
        )
        new_content.tap do |content|
          content.essence = new_essence
          content.save
        end
      end

      # Returns all content definitions from elements.yml
      #
      def definitions
        definitions = Element.definitions.flat_map { |e| e['contents'] }
        definitions.compact!
        definitions
      end

      # Returns a normalized Essence type
      #
      # Adds Alchemy module name in front of given essence type
      # unless there is a Class with the specified name that is an essence.
      #
      # @param [String]
      #   the essence type to normalize
      #
      def normalize_essence_type(essence_type)
        essence_type = essence_type.classify
        return essence_type if is_an_essence?(essence_type)

        "Alchemy::#{essence_type}"
      end

      private

      def is_an_essence?(essence_type)
        klass = Module.const_get(essence_type)
        klass.is_a?(Class) && klass.new.acts_as_essence?
      rescue NameError
        false
      end
    end

    # Instance Methods

    # Returns the definition hash from +elements.yml+ file.
    #
    def definition
      if element.blank?
        log_warning "Content with id #{id} is missing its Element."
        return {}
      end
      element.content_definition_for(name) || {}
    end

    # Creates essence from definition.
    #
    # If an optional type is passed, this type of essence gets created.
    #
    def create_essence!(type = nil)
      self.essence = essence_class(type).create!(prepared_attributes_for_essence)
      save!
    end

    private

    # Returns a class constant from definition's type field.
    #
    # If an optional type is passed, this type of essence gets constantized.
    #
    def essence_class(type = nil)
      Content.normalize_essence_type(type || definition['type']).constantize
    end

    # Prepares the attributes for creating the essence.
    #
    # 1. It sets a default text if given in +elements.yml+
    #
    def prepared_attributes_for_essence
      attributes = {
        ingredient: default_text(definition['default'])
      }
      attributes
    end
  end
end
