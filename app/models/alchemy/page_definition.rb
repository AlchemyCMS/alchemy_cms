# frozen_string_literal: true

module Alchemy
  class PageDefinition
    include ActiveModel::Model
    include ActiveModel::Attributes
    include Alchemy::Hints

    extend ActiveModel::Translation

    attribute :name, :string
    attribute :image, :string
    attribute :elements, default: []
    attribute :autogenerate, default: []
    attribute :layoutpage, :boolean, default: false
    attribute :unique, :boolean, default: false
    attribute :cache, default: true
    attribute :insert_elements_at, :string, default: "bottom"
    attribute :fixed_attributes, default: {}
    attribute :searchable, :boolean, default: true
    attribute :searchresults, :boolean, default: false
    attribute :hide, :boolean, default: false
    attribute :editable_by
    attribute :hint

    validates :name,
      presence: true,
      format: {
        with: /\A[a-z_-]+\z/
      }

    delegate :[], to: :attributes
    delegate :blank?, to: :name

    class << self
      # Returns all page layouts.
      #
      # They are defined in +config/alchemy/page_layout.yml+ file.
      #
      def all
        @definitions ||= read_definitions_file.map { new(**_1) }
      end

      def map(...)
        all.map(...)
      end
      alias_method :collect, :map

      # Add additional page definitions to collection.
      #
      # Useful for extending the page layouts from an Alchemy module.
      #
      # === Usage Example
      #
      #   Call +Alchemy::PageDefinition.add(your_definition)+ in your engine.rb file.
      #
      # @param [Array || Hash]
      #   You can pass a single layout definition as Hash, or a collection of page layouts as Array.
      #
      def add(definition)
        all
        @definitions += Array.wrap(definition).map { new(**_1) }
      end

      # Returns one page definition by given name.
      #
      def get(name)
        return new if name.blank?

        all.detect { _1.name.casecmp(name).zero? }
      end

      def reset!
        @definitions = nil
      end

      # The absolute +page_layouts.yml+ file path
      # @return [Pathname]
      def layouts_file_path
        Rails.root.join("config", "alchemy", "page_layouts.yml")
      end

      private

      # Reads the layout definitions from +config/alchemy/page_layouts.yml+.
      #
      def read_definitions_file
        if File.exist?(layouts_file_path)
          Array.wrap(
            YAML.safe_load(
              ERB.new(File.read(layouts_file_path)).result,
              permitted_classes: YAML_PERMITTED_CLASSES,
              aliases: true
            ) || []
          )
        else
          raise LoadError, "Could not find page_layouts.yml file! Please run `rails generate alchemy:install`"
        end
      end
    end

    def human_name
      Alchemy::Page.human_layout_name(name)
    end

    def attributes
      super.with_indifferent_access
    end

    private

    def hint_translation_scope
      :page_hints
    end
  end
end
