# frozen_string_literal: true

# == Schema Information
#
# Table name: alchemy_elements
#
#  id                :integer          not null, primary key
#  name              :string
#  position          :integer
#  page_id           :integer          not null
#  public            :boolean          default(TRUE)
#  folded            :boolean          default(FALSE)
#  unique            :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  creator_id        :integer
#  updater_id        :integer
#  cell_id           :integer
#  cached_tag_list   :text
#  parent_element_id :integer
#

module Alchemy
  class Element < BaseRecord
    include Alchemy::Logger
    include Alchemy::Taggable
    include Alchemy::Hints

    FORBIDDEN_DEFINITION_ATTRIBUTES = [
      "amount",
      "nestable_elements",
      "contents",
      "hint",
      "picture_gallery",
      "taggable",
      "compact"
    ].freeze

    SKIPPED_ATTRIBUTES_ON_COPY = [
      "cached_tag_list",
      "created_at",
      "creator_id",
      "id",
      "folded",
      "position",
      "updated_at",
      "updater_id"
    ].freeze

    # All Elements that share the same page id, cell id and parent element id are considered a list.
    #
    # If cell id and parent element id are nil (typical case for a simple page),
    # then all elements on that page are still in one list,
    # because acts_as_list correctly creates this statement:
    #
    #   WHERE page_id = 1 and cell_id = NULL AND parent_element_id = NULL
    #
    acts_as_list scope: [:page_id, :cell_id, :parent_element_id]

    stampable stamper_class_name: Alchemy.user_class_name

    # Content positions are scoped by their essence_type, so positions can be the same for different contents.
    # In order to get contents in creation order we also order them by id.
    has_many :contents, -> { order(:position, :id) }, dependent: :destroy

    # Elements can have other elements nested inside
    has_many :nested_elements,
      -> { order(:position).not_trashed },
      class_name: 'Alchemy::Element',
      foreign_key: :parent_element_id,
      dependent: :destroy

    belongs_to :cell, optional: true, touch: true
    belongs_to :page, touch: true, inverse_of: :descendent_elements

    # A nested element belongs to a parent element.
    belongs_to :parent_element,
      class_name: 'Alchemy::Element',
      optional: true,
      touch: true

    has_and_belongs_to_many :touchable_pages, -> { distinct },
      class_name: 'Alchemy::Page',
      join_table: ElementToPage.table_name

    validates_presence_of :name, on: :create
    validates_format_of :name, on: :create, with: /\A[a-z0-9_-]+\z/

    attr_accessor :create_contents_after_create

    after_create :create_contents, unless: proc { |e| e.create_contents_after_create == false }
    after_update :touch_touchable_pages

    scope :trashed,           -> { where(position: nil).order('updated_at DESC') }
    scope :not_trashed,       -> { where(Element.arel_table[:position].not_eq(nil)) }
    scope :published,         -> { where(public: true) }
    scope :not_restricted,    -> { joins(:page).merge(Page.not_restricted) }
    scope :available,         -> { published.not_trashed }
    scope :named,             ->(names) { where(name: names) }
    scope :excluded,          ->(names) { where(arel_table[:name].not_in(names)) }
    scope :not_in_cell,       -> { where(cell_id: nil) }
    scope :in_cell,           -> { where("#{table_name}.cell_id IS NOT NULL") }
    scope :from_current_site, -> { where(Language.table_name => {site_id: Site.current || Site.default}).joins(page: 'language') }
    scope :folded,            -> { where(folded: true) }
    scope :expanded,          -> { where(folded: false) }
    scope :not_nested,        -> { where(parent_element_id: nil) }

    delegate :restricted?, to: :page, allow_nil: true

    # Concerns
    include Alchemy::Element::Definitions
    include Alchemy::Element::ElementContents
    include Alchemy::Element::ElementEssences
    include Alchemy::Element::Presenters

    # class methods
    class << self
      # Builds a new element as described in +/config/alchemy/elements.yml+
      #
      # - Returns a new Alchemy::Element object if no name is given in attributes,
      #   because the definition can not be found w/o name
      # - Raises Alchemy::ElementDefinitionError if no definition for given attributes[:name]
      #   could be found
      #
      def new_from_scratch(attributes = {})
        return new if attributes[:name].blank?
        new_element_from_definition_by(attributes) || raise(ElementDefinitionError, attributes)
      end

      # Creates a new element as described in +/config/alchemy/elements.yml+
      #
      # - Returns a new Alchemy::Element object if no name is given in attributes,
      #   because the definition can not be found w/o name
      # - Raises Alchemy::ElementDefinitionError if no definition for given attributes[:name]
      #   could be found
      #
      def create_from_scratch(attributes)
        element = new_from_scratch(attributes)
        element.save if element
        element
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
                         create_contents_after_create: false,
                         tag_list: source_element.tag_list
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
        where(id: clipboard.collect { |e| e['id'] })
      end

      # All elements in clipboard that could be placed on page
      #
      def all_from_clipboard_for_page(clipboard, page)
        return [] if clipboard.nil? || page.nil?
        all_from_clipboard(clipboard).select { |ce|
          page.available_element_names.include?(ce.name)
        }
      end

      private

      def new_element_from_definition_by(attributes)
        element_attributes = attributes.to_h.merge(name: attributes[:name].split('#').first)
        element_definition = Element.definition_by_name(element_attributes[:name])
        return if element_definition.nil?

        new(element_definition.merge(element_attributes).except(*FORBIDDEN_DEFINITION_ATTRIBUTES))
      end
    end

    # Returns next public element from same page.
    #
    # Pass an element name to get next of this kind.
    #
    def next(name = nil)
      elements = page.elements.published.where('position > ?', position)
      select_element(elements, name, :asc)
    end

    # Returns previous public element from same page.
    #
    # Pass an element name to get previous of this kind.
    #
    def prev(name = nil)
      elements = page.elements.published.where('position < ?', position)
      select_element(elements, name, :desc)
    end

    # Stores the page into +touchable_pages+ (Pages that have to be touched after updating the element).
    def store_page(page)
      return true if page.nil?
      unless touchable_pages.include? page
        touchable_pages << page
        save
      end
    end

    # Trashing an element means nullifying its position, folding and unpublishing it.
    def trash!
      self.public = false
      self.folded = true
      remove_from_list
    end

    def trashed?
      position.nil?
    end

    # The names of all cells from given page this element could be placed in.
    #
    def available_page_cell_names(page)
      cellnames = unique_available_page_cell_names(page)
      if cellnames.blank? || !page.has_cells?
        ['for_other_elements']
      else
        cellnames
      end
    end

    # Returns true if the definition of this element has a taggable true value.
    def taggable?
      definition['taggable'] == true
    end

    # The opposite of folded?
    def expanded?
      !folded?
    end

    # Defined as compact element?
    def compact?
      definition['compact'] == true
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
      "alchemy/elements/#{name}_view"
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
      definition.fetch('nestable_elements', [])
    end

    # Copy all nested elements from current element to given target element.
    def copy_nested_elements_to(target_element)
      nested_elements.map do |nested_element|
        Element.copy(nested_element, {
          parent_element_id: target_element.id,
          page_id: target_element.page_id,
          cell_id: target_element.cell_id
        })
      end
    end

    private

    def select_element(elements, name, order)
      elements = elements.named(name) if name.present?
      elements.reorder(position: order).limit(1).first
    end

    # Returns all cells from given page this element could be placed in.
    #
    def available_page_cells(page)
      page.cells.select do |cell|
        cell.available_elements.include?(name)
      end
    end

    # Returns all uniq cell names from given page this element could be placed in.
    #
    def unique_available_page_cell_names(page)
      available_page_cells(page).collect(&:name).uniq
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
