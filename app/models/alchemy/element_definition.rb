# frozen_string_literal: true

module Alchemy
  class ElementDefinition
    include ActiveModel::Model
    include ActiveModel::Attributes
    include Alchemy::Hints

    extend ActiveModel::Translation

    attribute :name, :string
    attribute :unique, :boolean, default: false
    attribute :amount, :integer, default: Float::INFINITY
    attribute :taggable, :boolean, default: false
    attribute :compact, :boolean, default: false
    attribute :fixed, :boolean, default: false
    attribute :ingredients, default: []
    attribute :nestable_elements, default: []
    attribute :autogenerate, default: []
    attribute :deprecated
    attribute :message
    attribute :warning
    attribute :hint

    validates :name,
      presence: true,
      format: {
        with: /\A[a-z_-]+\z/
      }

    delegate :blank?, to: :name

    class << self
      # Returns the definitions from elements.yml file.
      #
      # Place a +elements.yml+ file inside your apps +config/alchemy+ folder to define
      # your own set of elements
      #
      def all
        @definitions ||= read_definitions_file.map { new(**_1) }
      end

      # Add additional page definitions to collection.
      #
      # Useful for extending the elements from an Alchemy module.
      #
      # === Usage Example
      #
      #   Call +Alchemy::ElementDefinition.add(your_definition)+ in your engine.rb file.
      #
      # @param [Array || Hash]
      #   You can pass a single element definition as Hash, or a collection of elements as Array.
      #
      def add(definition)
        all
        @definitions += Array.wrap(definition).map { new(**_1) }
      end

      # Returns one element definition by given name.
      #
      def get(name)
        return new if name.blank?

        all.detect { _1.name.casecmp(name).zero? }
      end

      def reset!
        @definitions = nil
      end

      # The absolute +elements.yml+ file path
      # @return [Pathname]
      def definitions_file_path
        Rails.root.join("config", "alchemy", "elements.yml")
      end

      private

      def definitions_file
        File.read(definitions_file_path)
      end

      def definitions_file_exist?
        File.exist?(definitions_file_path)
      end

      # Reads the element definitions from +config/alchemy/elements.yml+.
      #
      def read_definitions_file
        if definitions_file_exist?
          YAML.safe_load(
            ERB.new(definitions_file).result,
            permitted_classes: YAML_PERMITTED_CLASSES,
            aliases: true
          ) || []
        else
          raise LoadError,
            "Could not find elements.yml file! Please run `rails generate alchemy:install`"
        end
      end
    end

    def attributes
      super.with_indifferent_access
    end
    alias_method :definition, :attributes

    def ingredients
      super.map(&:with_indifferent_access)
    end

    # Returns a deprecation notice for elements marked deprecated
    #
    # You can either use localizations or pass a String as notice
    # in the element definition.
    #
    # == Custom deprecation notices
    #
    # Use general element deprecation notice
    #
    #     - name: old_element
    #       deprecated: true
    #
    # Add a translation to your locale file for a per element notice.
    #
    #     en:
    #       alchemy:
    #         element_deprecation_notices:
    #           old_element: Foo baz widget is deprecated
    #
    # or use the global translation that apply to all deprecated elements.
    #
    #     en:
    #       alchemy:
    #         element_deprecation_notice: Foo baz widget is deprecated
    #
    # or pass string as deprecation notice.
    #
    #     - name: old_element
    #       deprecated: This element will be removed soon.
    #
    def deprecation_notice
      case deprecated
      when String
        deprecated
      when TrueClass
        Alchemy.t(
          name,
          scope: :element_deprecation_notices,
          default: Alchemy.t(:element_deprecated)
        )
      end
    end

    private

    def hint_translation_scope
      :element_hints
    end
  end
end
