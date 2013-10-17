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
      #   The content description used for finding the content in +elements.yml+ file
      #
      def build(element, essence_hash)
        if (description = content_description(element, essence_hash)).blank?
          raise ContentDefinitionError, "No description found in elements.yml for #{essence_hash.inspect} and #{element.inspect}"
        else
          new(name: description['name'], element_id: element.id)
        end
      end

      # Creates a new content from elements description in the +elements.yml+ file.
      #
      # 1. It builds the content
      # 2. It creates the essence record (content object gets saved)
      #
      # @return [Alchemy::Content]
      #
      def create_from_scratch(element, essence_hash)
        essence_hash.stringify_keys!
        if content = build(element, essence_hash)
          content.create_essence!(essence_hash['essence_type'])
        end
        content
      end

      # Makes a copy of source and also copies the associated essence.
      #
      # You can pass a differences hash to update the attributes of the copy.
      #
      # === Example
      #
      #   @copy = Alchemy::Content.copy(@content, {:element_id => 3})
      #   @copy.element_id # => 3
      #
      def copy(source, differences = {})
        attributes = source.attributes.except(*SKIPPED_ATTRIBUTES_ON_COPY).merge(differences.stringify_keys)
        content = self.create!(attributes)
        new_essence = content.essence.class.new(content.essence.attributes.except(*SKIPPED_ATTRIBUTES_ON_COPY))
        new_essence.save!
        raise "Essence not cloned" if new_essence.id == content.essence_id
        content.update_attributes(essence_id: new_essence.id)
        content
      end

      # Returns the content description for building a content.
      #
      # 1. It looks in the element's contents description
      # 2. It builds a description hash from essence type, if the the name key is not present
      #
      def content_description(element, essence_hash)
        essence_hash.stringify_keys!
        # No name given. We build the content from essence type.
        if essence_hash['name'].blank? && essence_hash['essence_type'].present?
          content_description_from_essence_type(element, essence_hash['essence_type'])
        else
          content_description_from_element(element, essence_hash['name'])
        end
      end

      # Returns a hash for building a content from essence type.
      #
      # @param [Alchemy::Element]
      #   The element the content is for.
      # @param [String]
      #   The essence type the content is from
      #
      def content_description_from_essence_type(element, essence_type)
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

      # Returns the content description hash from element.
      #
      # It first uses the normal content description described in the +elements.yml+ +contents+ array.
      #
      # If the content description could not be found it tries to load it from +available_contents+ array.
      #
      # @param [Alchemy::Element]
      #   The element instance the content is for
      # @param [String]
      #   The name of the content
      #
      def content_description_from_element(element, name)
        element.content_description_for(name) ||
          element.available_content_description_for(name)
      end

      # Returns all content descriptions from elements.yml
      #
      def descriptions
        Element.descriptions.collect { |e| e['contents'] }.flatten.compact
      end

      # Returns a normalized Essence type
      #
      # Adds Alchemy module name in front of given essence type
      #
      # @param [String]
      #   the essence type to normalize
      #
      def normalize_essence_type(essence_type)
        essence_type = essence_type.classify
        if essence_type.match(/\AAlchemy::/)
          essence_type
        else
          essence_type.gsub!(/\AEssence/, 'Alchemy::Essence')
        end
      end

    end # end class methods

    # Instance Methods

    # Returns the description hash from +elements.yml+ file.
    #
    def description
      if element.blank?
        log_warning "Content with id #{self.id} is missing its Element."
        return {}
      end
      Content.content_description_from_element(element, name) || {}
    end
    alias_method :definition, :description

    # Creates essence from description.
    #
    # If an optional type is passed, this type of essence gets created.
    #
    def create_essence!(type = nil)
      self.essence = essence_class(type).create!(prepared_attributes_for_essence)
      self.save!
    end

  private

    # Returns a class constant from description's type field.
    #
    # If an optional type is passed, this type of essence gets constantized.
    #
    def essence_class(type = nil)
      Content.normalize_essence_type(type || description['type']).constantize
    end

    # Prepares the attributes for creating the essence.
    #
    # 1. It sets a default text if given in +elements.yml+
    #
    def prepared_attributes_for_essence
      attributes = {
        ingredient: default_text(description['default'])
      }
      attributes
    end

  end
end
