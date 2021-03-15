# frozen_string_literal: true

# == Schema Information
#
# Table name: alchemy_elements
#
#  id                :integer          not null, primary key
#  name              :string
#  position          :integer
#  page_version_id   :integer          not null
#  public            :boolean          default(TRUE)
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
require_dependency "alchemy/element/element_contents"
require_dependency "alchemy/element/element_essences"
require_dependency "alchemy/element/presenters"

module Alchemy
  class Element < BaseRecord
    NAME_REGEXP = /\A[a-z0-9_-]+\z/

    include Alchemy::Logger
    include Alchemy::Taggable
    include Alchemy::Hints

    FORBIDDEN_DEFINITION_ATTRIBUTES = [
      "amount",
      "autogenerate",
      "nestable_elements",
      "contents",
      "hint",
      "taggable",
      "compact",
      "message",
      "deprecated",
    ].freeze

    SKIPPED_ATTRIBUTES_ON_COPY = [
      "cached_tag_list",
      "created_at",
      "creator_id",
      "id",
      "folded",
      "position",
      "updated_at",
      "updater_id",
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

    stampable stamper_class_name: Alchemy.user_class_name

    has_many :contents, dependent: :destroy, inverse_of: :element

    has_many :all_nested_elements,
      -> { order(:position) },
      class_name: "Alchemy::Element",
      foreign_key: :parent_element_id,
      dependent: :destroy

    has_many :nested_elements,
      -> { order(:position).available },
      class_name: "Alchemy::Element",
      foreign_key: :parent_element_id,
      dependent: :destroy,
      inverse_of: :parent_element

    belongs_to :page_version, touch: true, inverse_of: :elements
    has_one :page, through: :page_version

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

    attr_accessor :autogenerate_contents
    attr_accessor :autogenerate_nested_elements
    after_create :create_contents, unless: -> { autogenerate_contents == false }
    after_create :generate_nested_elements, unless: -> { autogenerate_nested_elements == false }

    after_update :touch_touchable_pages

    scope :published, -> { where(public: true) }
    scope :hidden, -> { where(public: false) }
    scope :not_restricted, -> { joins(:page).merge(Page.not_restricted) }
    scope :available, -> { published }
    scope :named, ->(names) { where(name: names) }
    scope :excluded, ->(names) { where.not(name: names) }
    scope :fixed, -> { where(fixed: true) }
    scope :unfixed, -> { where(fixed: false) }
    scope :from_current_site, -> { where(Language.table_name => { site_id: Site.current || Site.default }).joins(page: "language") }
    scope :folded, -> { where(folded: true) }
    scope :expanded, -> { where(folded: false) }
    scope :not_nested, -> { where(parent_element_id: nil) }

    delegate :restricted?, to: :page, allow_nil: true

    # Concerns
    include Definitions
    include ElementContents
    include ElementEssences
    include Presenters

    # class methods
    class << self
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

        super(element_definition.merge(element_attributes).except(*FORBIDDEN_DEFINITION_ATTRIBUTES))
      end

      # This methods does a copy of source and all depending contents and all of their depending essences.
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
        attributes = source_element.attributes.with_indifferent_access
          .except(*SKIPPED_ATTRIBUTES_ON_COPY)
          .merge(differences)
          .merge({
            autogenerate_contents: false,
            autogenerate_nested_elements: false,
            tag_list: source_element.tag_list,
          })

        new_element = create!(attributes)

        if source_element.contents.any?
          source_element.copy_contents_to(new_element)
        end

        if source_element.nested_elements.any?
          source_element.copy_nested_elements_to(new_element)
        end

        new_element
      end

      def all_from_clipboard(clipboard)
        return [] if clipboard.nil?

        where(id: clipboard.collect { |e| e["id"] })
      end

      # All elements in clipboard that could be placed on page
      #
      def all_from_clipboard_for_page(clipboard, page)
        return [] if clipboard.nil? || page.nil?

        all_from_clipboard(clipboard).select { |ce|
          page.available_element_names.include?(ce.name)
        }
      end
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

    # Returns true if the definition of this element has a taggable true value.
    def taggable?
      definition["taggable"] == true
    end

    # The opposite of folded?
    def expanded?
      !folded?
    end

    # Defined as compact element?
    def compact?
      definition["compact"] == true
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
      !!definition["deprecated"]
    end

    # The element's view partial is dependent from its name
    #
    # == Define elements
    #
    # Elements are defined in the +config/alchemy/elements.yml+ file
    #
    #     - name: article
    #       contents:
    #       ...
    #
    # == Override the view
    #
    # Element partials live in +app/views/alchemy/elements+
    #
    def to_partial_path
      "alchemy/elements/#{name}"
    end

    # Returns the key that's taken for cache path.
    #
    # Uses the page's +published_at+ value that's updated when the user publishes the page.
    #
    # If the page is the current preview it uses the element's updated_at value as cache key.
    #
    def cache_key
      if Page.current_preview == page
        "alchemy/elements/#{id}-#{updated_at}"
      else
        "alchemy/elements/#{id}-#{page.published_at}"
      end
    end

    # A collection of element names that can be nested inside this element.
    def nestable_elements
      definition.fetch("nestable_elements", [])
    end

    # Copy all nested elements from current element to given target element.
    def copy_nested_elements_to(target_element)
      nested_elements.map do |nested_element|
        Element.copy(nested_element, {
          parent_element_id: target_element.id,
          page_version_id: target_element.page_version_id,
        })
      end
    end

    private

    def generate_nested_elements
      definition.fetch("autogenerate", []).each do |nestable_element|
        if nestable_elements.include?(nestable_element)
          Element.create(page_version: page_version, parent_element_id: id, name: nestable_element)
        else
          log_warning("Element '#{nestable_element}' not a nestable element for '#{name}'. Skipping!")
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
  end
end
