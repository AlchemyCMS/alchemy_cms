# frozen_string_literal: true

module Alchemy
  class Node < BaseRecord
    VALID_URL_REGEX = /\A(\/|\D[a-z+\d.-]+:)/

    before_destroy :check_if_related_node_ingredients_present

    acts_as_nested_set scope: "language_id", touch: true
    stampable stamper_class_name: Alchemy.user_class_name

    belongs_to :language, class_name: "Alchemy::Language"
    belongs_to :page, class_name: "Alchemy::Page", optional: true, inverse_of: :nodes

    has_one :site, through: :language

    has_many :node_ingredients,
      class_name: "Alchemy::Ingredients::Node",
      foreign_key: :related_object_id,
      inverse_of: :related_object

    before_validation :translate_root_menu_name, if: -> { root? }
    before_validation :set_menu_type_from_root, unless: -> { root? }

    validates :menu_type, presence: true
    validates :name, presence: true, if: -> { page.nil? }
    validates :url, format: {with: VALID_URL_REGEX}, unless: -> { url.nil? }

    # Returns the name
    #
    # Either the value is stored in the database
    # or, if attached, the values comes from a page.
    def name
      read_attribute(:name).presence || page&.name
    end

    class << self
      # Returns all root nodes for current language
      def language_root_nodes
        raise "No language found" if Current.language.nil?

        roots.where(language_id: Current.language.id)
      end

      def available_menu_names
        read_definitions_file
      end

      private

      def searchable_alchemy_resource_associations
        %w[page]
      end

      # Reads the element definitions file named +menus.yml+ from +config/alchemy/+ folder.
      #
      def read_definitions_file
        if ::File.exist?(definitions_file_path)
          ::YAML.safe_load_file(definitions_file_path) || []
        else
          raise LoadError, "Could not find menus.yml file! Please run `rails generate alchemy:install`"
        end
      end

      # Returns the +menus.yml+ file path
      #
      def definitions_file_path
        Rails.root.join "config/alchemy/menus.yml"
      end
    end

    # Returns the url
    #
    # Either the value is stored in the database, aka. an external url.
    # Or, if attached, the values comes from a page.
    def url
      page&.url_path || read_attribute(:url).presence
    end

    def to_partial_path
      "alchemy/menus/#{menu_type}/node"
    end

    private

    def check_if_related_node_ingredients_present
      dependent_node_ingredients = self_and_descendants.flat_map(&:node_ingredients)
      if dependent_node_ingredients.any?
        errors.add(:base, :node_ingredients_present, page_names: dependent_node_ingredients.map { |i| i.element&.page&.name }.to_sentence)
        throw(:abort)
      end
    end

    def translate_root_menu_name
      self.name ||= Alchemy.t(menu_type, scope: :menu_names)
    end

    def set_menu_type_from_root
      self.menu_type = root.menu_type
    end
  end
end
