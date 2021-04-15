# frozen_string_literal: true

module Alchemy
  # Holds everything concerning the building and creating of contents and the related essence object.
  #
  module Content::Factory
    extend ActiveSupport::Concern

    module ClassMethods
      SKIPPED_ATTRIBUTES_ON_COPY = %w(position created_at updated_at creator_id updater_id element_id id)

      # Builds a new content as descriped in the elements.yml file.
      #
      # @param [Hash]
      #   The content definition used for finding the content in +elements.yml+ file
      #
      def new(attributes = {})
        element = attributes[:element] || Element.find_by(id: attributes[:element_id])
        return super if attributes.empty? || element.nil?

        definition = element.content_definition_for(attributes[:name])
        if definition.blank? && attributes[:essence_type].nil?
          raise ContentDefinitionError, "No definition found in elements.yml for #{attributes.inspect} and #{element.inspect}"
        end

        super(
          name: attributes[:name],
          essence_type: attributes[:essence_type] || normalize_essence_type(definition[:type]),
          element: element
        ).tap(&:build_essence)
      end

      # Creates a new content from elements definition in the +elements.yml+ file.
      #
      # 1. It builds the content
      # 2. It creates the essence record (content object gets saved)
      #
      # @return [Alchemy::Content]
      #
      def create(attributes = {})
        new(attributes).tap do |content|
          content.essence.save && content.save
        end
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
        Content.new(
          source.attributes.with_indifferent_access.
            except(*SKIPPED_ATTRIBUTES_ON_COPY).
            merge(differences.with_indifferent_access)
        ).tap do |new_content|
          new_content.build_essence(
            source.essence.attributes.
              except(*SKIPPED_ATTRIBUTES_ON_COPY)
          )
          new_content.save
        end
      end

      # Returns all content definitions from elements.yml
      #
      def definitions
        definitions = Element.definitions.flat_map { |e| e["contents"] }
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

    # Build essence from definition.
    #
    # If an optional type is passed, this type of essence gets created.
    #
    def build_essence(attributes = {})
      self.essence = essence_class.new(
        { content: self, ingredient: default_value }.merge(attributes)
      )
    end

    # Creates essence from definition.
    #
    # If an optional type is passed, this type of essence gets created.
    #
    def create_essence!(attrs = {})
      build_essence(attrs).save!
      save!
    end

    private

    # Returns a class constant from definition's type field or the essence_type column
    #
    def essence_class
      (essence_type || Content.normalize_essence_type(definition["type"])).constantize
    end
  end
end
