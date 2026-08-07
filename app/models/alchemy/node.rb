# frozen_string_literal: true

module Alchemy
  class Node < BaseRecord
    include Alchemy::RelatableResource

    VALID_URL_REGEX = /\A(\/|\D[a-z+\d.-]+:)/
    SKIPPED_ATTRIBUTES_ON_COPY = %w[id created_at updated_at creator_id updater_id lft rgt depth parent_id]

    before_destroy :check_if_related_node_ingredients_present

    acts_as_nested_set scope: "language_id", touch: true
    stampable stamper_class_name: Alchemy.config.user_class_name

    belongs_to :language, class_name: "Alchemy::Language"
    belongs_to :page, class_name: "Alchemy::Page", optional: true, inverse_of: :nodes

    has_one :site, through: :language

    has_many :node_ingredients,
      class_name: "Alchemy::Ingredients::Node",
      foreign_key: :related_object_id,
      inverse_of: :related_object

    # All nodes of the current site whose language is published.
    scope :from_current_public_site, -> {
      joins(:language)
        .where(Alchemy::Language.table_name => {site_id: Alchemy::Current.site})
        .merge(Alchemy::Language.published)
    }

    # Nodes an anonymous visitor may see: external links or nodes attached to a
    # published, unrestricted page, scoped to the current site.
    scope :available_to_guests, -> {
      from_current_public_site.where(page: nil)
        .or(from_current_public_site.where(page: Alchemy::Page.published.not_restricted))
    }

    # Like #available_to_guests but including nodes attached to restricted pages,
    # which logged in members are allowed to see.
    scope :available_to_members, -> {
      Alchemy::Deprecation.warn("Node.available_to_members is deprecated and will be removed in Alchemy 9.0. Use Node.available_to(user) instead.")
      from_current_public_site.where(page: nil)
        .or(from_current_public_site.where(page: Alchemy::Page.published))
    }

    # Nodes the given user may see: external links or nodes attached to a
    # published page the user is allowed to read. Mirrors +Page#readable_by?+
    # so a node never reveals a page the user cannot open. Passing +nil+ yields
    # the same result as #available_to_guests.
    scope :available_to, ->(user) {
      from_current_public_site.where(page: nil)
        .or(from_current_public_site.where(page: Alchemy::Page.published.readable_by(user)))
    }

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

    # Direct children whose attached page the given user is allowed to read.
    #
    # Nodes without a page (external links) are always included. Menu partials
    # render through this so a restricted page never appears in navigation for
    # a user who cannot open it. +permitted_roles+ is a column, so +readable_by?+
    # adds no query per node beyond the eager loaded page.
    def readable_children(user)
      children.includes(:page, :children).select do |node|
        node.page.nil? || node.page.readable_by?(user)
      end
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

      def all_from_clipboard(clipboard)
        return [] if clipboard.blank?

        where(id: clipboard.collect { |n| n["id"] })
      end

      def copy_and_paste(source, new_parent, new_name)
        # Prevent pasting a node as a child of itself or any of its descendants
        return if new_parent && source.is_or_is_ancestor_of?(new_parent)

        attributes = source.attributes.except(*SKIPPED_ATTRIBUTES_ON_COPY).merge(
          name: new_name,
          parent: new_parent,
          language: new_parent&.language || source.language
        )

        node = create!(attributes)

        # Copy all descendants
        source.children.each do |child|
          copy_and_paste(child, node, child.name)
        end

        node
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
