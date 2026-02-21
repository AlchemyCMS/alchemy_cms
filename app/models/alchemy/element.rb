# frozen_string_literal: true

# == Schema Information
#
# Table name: alchemy_elements
#
#  id                :integer          not null, primary key
#  name              :string
#  position          :integer
#  page_version_id   :integer          not null
#  public_on         :timestamp
#  public_until      :timestamp
#  fixed             :boolean          default(FALSE)
#  folded            :boolean          default(FALSE)
#  unique            :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  creator_id        :integer
#  updater_id        :integer
#  cached_tag_list   :text
#  parent_element_id :integer
#

require_dependency "alchemy/element/definitions"
require_dependency "alchemy/element/element_ingredients"
require_dependency "alchemy/element/presenters"

module Alchemy
  class Element < BaseRecord
    NAME_REGEXP = /\A[a-z0-9_-]+\z/

    # These columns are deprecated in favor of publication time stamps
    self.ignored_columns += [
      "public"
    ]

    include Alchemy::Taggable
    include Publishable

    attr_accessor :skip_ingredient_validations

    FORBIDDEN_DEFINITION_ATTRIBUTES = [
      "amount",
      "autogenerate",
      "compact",
      "deprecated",
      "hint",
      "icon",
      "ingredients",
      "message",
      "nestable_elements",
      "searchable",
      "taggable",
      "warning"
    ].freeze

    # All Elements that share the same page version and parent element and are fixed or not are considered a list.
    #
    # If parent_element_id is nil (typical case for a simple page),
    # then all elements on that page are still in one list,
    # because acts_as_list correctly creates this statement:
    #
    #   WHERE page_version_id = 1 and fixed = FALSE AND parent_element_id = NULL
    #
    acts_as_list scope: [:page_version_id, :fixed, :parent_element_id]

    stampable stamper_class_name: Alchemy.config.user_class_name

    before_destroy :delete_all_nested_elements

    has_many :all_nested_elements,
      -> { order(:position) },
      class_name: "Alchemy::Element",
      foreign_key: :parent_element_id,
      dependent: :destroy

    has_many :nested_elements,
      -> { order(:position).published },
      class_name: "Alchemy::Element",
      foreign_key: :parent_element_id,
      dependent: :destroy,
      inverse_of: :parent_element

    belongs_to :page_version, touch: true, inverse_of: :elements
    has_one :page, through: :page_version
    has_one :language, through: :page

    # A nested element belongs to a parent element.
    belongs_to :parent_element,
      class_name: "Alchemy::Element",
      optional: true,
      touch: true,
      inverse_of: :nested_elements

    has_and_belongs_to_many :touchable_pages, -> { distinct },
      class_name: "Alchemy::Page",
      join_table: ElementToPage.table_name

    validates_presence_of :name, on: :create
    validates_format_of :name, on: :create, with: NAME_REGEXP
    validate :validate_same_page_version_as_parent

    after_initialize :set_default_public_on, if: :new_record?

    attr_accessor :autogenerate_nested_elements
    after_create :generate_nested_elements, unless: -> { autogenerate_nested_elements == false }

    after_update :touch_touchable_pages

    scope :not_restricted, -> { joins(:page).merge(Page.not_restricted) }
    scope :named, ->(names) { where(name: names) }
    scope :excluded, ->(names) { where.not(name: names) }
    scope :fixed, -> { where(fixed: true) }
    scope :unfixed, -> { where(fixed: false) }
    scope :from_current_site, -> { where(Language.table_name => {site_id: Current.site}).joins(page: "language") }
    scope :folded, -> { where(folded: true) }
    scope :expanded, -> { where(folded: false) }
    scope :not_nested, -> { where(parent_element_id: nil) }

    delegate :restricted?, to: :page, allow_nil: true
    delegate :deprecation_notice, :has_hint?, :hint, to: :definition

    # Concerns
    include Definitions
    include ElementIngredients
    include Presenters

    # class methods
    class << self
      alias_method :hidden, :draft
      deprecate hidden: :draft, deprecator: Alchemy::Deprecation

      # Builds a new element as described in +/config/alchemy/elements.yml+
      #
      # - Returns a new Alchemy::Element object if no name is given in attributes,
      #   because the definition can not be found w/o name
      # - Raises Alchemy::ElementDefinitionError if no definition for given attributes[:name]
      #   could be found
      #
      def new(attributes = {})
        return super if attributes[:name].blank?

        element_attributes = attributes.to_h.merge(name: attributes[:name].split("#").first)
        element_definition = Element.definition_by_name(element_attributes[:name])
        if element_definition.nil?
          raise(ElementDefinitionError, attributes)
        end

        super(element_definition.attributes.merge(element_attributes).except(*FORBIDDEN_DEFINITION_ATTRIBUTES))
      end

      # This methods does a copy of source and all its ingredients.
      #
      # == Options
      #
      # You can pass a differences Hash as second option to update attributes for the copy.
      #
      # == Example
      #
      #   @copy = Alchemy::Element.copy(@element, {public: false})
      #   @copy.public? # => false
      #
      def copy(source_element, differences = {})
        Alchemy::DuplicateElement.new(source_element).call(differences)
      end

      def all_from_clipboard(clipboard)
        return none if clipboard.nil?

        where(id: clipboard.collect { |e| e["id"] })
      end

      # All elements in clipboard that could be placed on page
      #
      def all_from_clipboard_for_page(clipboard, page)
        return none if clipboard.nil? || page.nil?

        all_from_clipboard(clipboard).where(name: page.available_element_names)
      end

      # All elements in clipboard that could be placed as a child of `parent_element`
      def all_from_clipboard_for_parent_element(clipboard, parent_element)
        return none if clipboard.nil? || parent_element.nil?

        all_from_clipboard(clipboard).where(name: parent_element.definition.nestable_elements)
      end
    end

    # Returns IDs of all folded parent elements from immediate parent up to root
    #
    # Walks up the ancestor chain and collects only the ones that are folded,
    # skipping already expanded parents.
    #
    # @return [Array<Integer>] Folded parent element IDs from immediate parent to root
    def folded_parent_element_ids
      return [] unless parent_element_id

      ids = []
      current_id = parent_element_id
      while current_id
        folded, parent_id = self.class.where(id: current_id).pick(:folded, :parent_element_id)
        ids << current_id if folded
        current_id = parent_id
      end
      ids
    end

    # Returns next public element from same page.
    #
    # Pass an element name to get next of this kind.
    #
    def next(name = nil)
      elements = page.elements.published.where("position > ?", position)
      select_element(elements, name, :asc)
    end

    # Returns previous public element from same page.
    #
    # Pass an element name to get previous of this kind.
    #
    def prev(name = nil)
      elements = page.elements.published.where("position < ?", position)
      select_element(elements, name, :desc)
    end

    # Stores the page into +touchable_pages+ (Pages that have to be touched after updating the element).
    def store_page(page)
      return true if page.nil?

      unless touchable_pages.include? page
        touchable_pages << page
      end
    end

    # Convenience setter to set public_on attribute
    # when setting public to true or false.
    def public=(value)
      @public_on_explicitely_set = true
      if ActiveModel::Type::Boolean.new.cast(value)
        self.public_on = Time.current
        self.public_until = nil
      else
        self.public_until = Time.current
      end
    end

    # Override setter to track if public_on was already set
    # in order to not override it with default value if someone
    # explicitly set it to nil.
    def public_on=(value)
      @public_on_explicitely_set = true
      super
    end

    # Returns true if the definition of this element has a taggable true value.
    def taggable?
      definition.taggable == true
    end

    # The opposite of folded?
    def expanded?
      !folded?
    end

    # Defined as compact element?
    def compact?
      definition.compact
    end

    # Defined as deprecated element?
    #
    # You can either set true or a String on your elements definition.
    #
    # == Passing true
    #
    #     - name: old_element
    #       deprecated: true
    #
    # The deprecation notice can be translated. Either as global notice for all deprecated elements.
    #
    #     en:
    #       alchemy:
    #         element_deprecation_notice: Foo baz widget is deprecated
    #
    # Or add a translation to your locale file for a per element notice.
    #
    #     en:
    #       alchemy:
    #         element_deprecation_notices:
    #           old_element: Foo baz widget is deprecated
    #
    # == Pass a String
    #
    #     - name: old_element
    #       deprecated: This element will be removed soon.
    #
    # @return Boolean
    def deprecated?
      !!definition.deprecated
    end

    # The element's view partial is dependent from its name
    #
    # == Define elements
    #
    # Elements are defined in the +config/alchemy/elements.yml+ file
    #
    #     - name: article
    #       ingredients:
    #       ...
    #
    # == Override the view
    #
    # Element partials live in +app/views/alchemy/elements+
    #
    def to_partial_path
      "alchemy/elements/#{name}"
    end

    # A collection of element names that can be nested inside this element.
    def nestable_elements
      definition.nestable_elements
    end

    private

    def set_default_public_on
      return if @public_on_explicitely_set
      self.public_on ||= Time.current
    end

    def validate_same_page_version_as_parent
      return unless parent_element
      return if page_version_id == parent_element.page_version_id

      errors.add(:page_version_id, :must_match_parent)
    end

    def generate_nested_elements
      definition.autogenerate.each do |nestable_element|
        if nestable_elements.include?(nestable_element)
          Element.create(page_version: page_version, parent_element_id: id, name: nestable_element)
        else
          Logger.warn("Element '#{nestable_element}' not a nestable element for '#{name}'. Skipping!")
        end
      end
    end

    def select_element(elements, name, order)
      elements = elements.named(name) if name.present?
      elements.reorder(position: order).limit(1).first
    end

    # Updates all +touchable_pages+
    #
    # Called after_update
    #
    def touch_touchable_pages
      return unless respond_to?(:touchable_pages)

      touchable_pages.each(&:touch)
    end

    def delete_all_nested_elements
      deeply_nested_elements = descendent_elements(self).flatten
      DeleteElements.new(deeply_nested_elements).call
      nested_elements.reset
      all_nested_elements.reset
    end

    def descendent_elements(element)
      element.all_nested_elements + element.all_nested_elements.map do |nested_element|
        descendent_elements(nested_element)
      end
    end
  end
end
