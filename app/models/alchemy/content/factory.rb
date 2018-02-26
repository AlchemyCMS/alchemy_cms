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
      # @param [Alchemy::Element]
      #   The element the content is for
      # @param [Hash]
      #   The content definition used for finding the content in +elements.yml+ file
      #
      def build(element, essence_hash)
        definition = content_definition(element, essence_hash)
        if definition.blank?
          raise ContentDefinitionError, "No definition found in elements.yml for #{essence_hash.inspect} and #{element.inspect}"
        else
          new(name: definition['name'], element_id: element.id)
        end
      end

      # Creates a new content from elements definition in the +elements.yml+ file.
      #
      # 1. It builds the content
      # 2. It creates the essence record (content object gets saved)
      #
      # @return [Alchemy::Content]
      #
      def create_from_scratch(element, essence_hash)
        if content = build(element, essence_hash)
          content.create_essence!(essence_hash[:essence_type])
        end
        content
      end

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
          source.attributes.except(*SKIPPED_ATTRIBUTES_ON_COPY).merge(differences)
        )

        new_essence = new_content.essence.class.create!(
          new_content.essence.attributes.except(*SKIPPED_ATTRIBUTES_ON_COPY)
        )

        new_content.update!(essence_id: new_essence.id)
        new_content
      end

      # Returns the content definition for building a content.
      #
      # 1. It looks in the element's contents definition
      # 2. It builds a definition hash from essence type, if the the name key is not present
      #
      def content_definition(element, essence_hash)
        # No name given. We build the content from essence type.
        if essence_hash[:name].blank? && essence_hash[:essence_type].present?
          content_definition_from_essence_type(element, essence_hash[:essence_type])
        else
          element.content_definition_for(essence_hash[:name])
        end
      end

      # Returns a hash for building a content from essence type.
      #
      # @param [Alchemy::Element]
      #   The element the content is for.
      # @param [String]
      #   The essence type the content is from
      #
      def content_definition_from_essence_type(element, essence_type)
        {
          'type' => essence_type,
          'name' => content_name_from_element_and_essence_type(element, essence_type)
        }
      end

      # A name for content from its essence type and amount of same essences in element.
      #
      # Example:
      #
      #   essence_picture_1
      #
      def content_name_from_element_and_essence_type(element, essence_type)
        essences_of_same_type = element.contents.where(essence_type: normalize_essence_type(essence_type))
        "#{essence_type.classify.demodulize.underscore}_#{essences_of_same_type.count + 1}"
      end

      # Returns all content definitions from elements.yml
      #
      def definitions
        Element.definitions.collect { |e| e['contents'] }.flatten.compact
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
