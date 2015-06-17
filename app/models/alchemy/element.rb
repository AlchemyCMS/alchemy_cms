# == Schema Information
#
# Table name: alchemy_elements
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  position        :integer
#  page_id         :integer
#  public          :boolean          default(TRUE)
#  folded          :boolean          default(FALSE)
#  unique          :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  creator_id      :integer
#  updater_id      :integer
#  cell_id         :integer
#  cached_tag_list :text
#

module Alchemy
  class Element < ActiveRecord::Base
    include Alchemy::Logger
    include Alchemy::Touching
    include Alchemy::Hints

    FORBIDDEN_DEFINITION_ATTRIBUTES = %w(contents available_contents amount picture_gallery taggable hint)
    SKIPPED_ATTRIBUTES_ON_COPY = %w(id position folded created_at updated_at creator_id updater_id cached_tag_list)

    acts_as_taggable

    # All Elements inside a cell are a list. All Elements not in cell are in the cell_id.nil list.
    acts_as_list scope: [:page_id, :cell_id]
    stampable stamper_class_name: Alchemy.user_class_name

    has_many :contents, -> { order(:position) }, dependent: :destroy
    belongs_to :cell
    belongs_to :page
    has_and_belongs_to_many :touchable_pages, -> { uniq },
      class_name: 'Alchemy::Page',
      join_table: ElementToPage.table_name

    validates_presence_of :name, :on => :create
    validates_format_of :name, :on => :create, :with => /\A[a-z0-9_-]+\z/

    attr_accessor :create_contents_after_create

    after_create :create_contents, :unless => proc { |e| e.create_contents_after_create == false }
    after_update :touch_pages
    after_update :touch_cell, unless: -> { self.cell.nil? }

    scope :trashed,           -> { where(position: nil).order('updated_at DESC') }
    scope :not_trashed,       -> { where(Element.arel_table[:position].not_eq(nil)) }
    scope :published,         -> { where(public: true) }
    scope :not_restricted,    -> { joins(:page).merge(Page.not_restricted) }
    scope :available,         -> { published.not_trashed }
    scope :named,             ->(names) { where(name: names) }
    scope :excluded,          ->(names) { where(arel_table[:name].not_in(names)) }
    scope :not_in_cell,       -> { where(cell_id: nil) }
    scope :in_cell,           -> { where("#{self.table_name}.cell_id IS NOT NULL") }
    scope :from_current_site, -> { where(Language.table_name => {site_id: Site.current || Site.default}).joins(page: 'language') }

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
        attributes = attributes.dup.symbolize_keys

        return new if attributes[:name].blank?

        new_element_from_definition_by(attributes) ||
          raise(ElementDefinitionError.new(attributes))
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
      #   @copy = Alchemy::Element.copy(@element, {:public => false})
      #   @copy.public? # => false
      #
      def copy(source, differences = {})
        source.attributes.stringify_keys!
        differences.stringify_keys!
        attributes = source.attributes.except(*SKIPPED_ATTRIBUTES_ON_COPY).merge(differences)
        element = self.create!(attributes.merge(:create_contents_after_create => false))
        element.tag_list = source.tag_list
        source.contents.each do |content|
          new_content = Content.copy(content, :element_id => element.id)
          new_content.move_to_bottom
        end
        element
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
        remove_cell_name_from_element_name!(attributes)

        element_scratch = definitions.detect { |el| el['name'] == attributes[:name] }
        return if element_scratch.nil?

        new(element_scratch.merge(attributes).except(*FORBIDDEN_DEFINITION_ATTRIBUTES))
      end

      def remove_cell_name_from_element_name!(attributes)
        attributes[:name] = attributes[:name].split('#').first
      end
    end

    # Returns next public element from same page.
    #
    # Pass an element name to get next of this kind.
    #
    def next(name = nil)
      previous_or_next('>', name)
    end

    # Returns previous public element from same page.
    #
    # Pass an element name to get previous of this kind.
    #
    def prev(name = nil)
      previous_or_next('<', name)
    end

    # Stores the page into +touchable_pages+ (Pages that have to be touched after updating the element).
    def store_page(page)
      return true if page.nil?
      unless self.touchable_pages.include? page
        self.touchable_pages << page
        self.save
      end
    end

    # Trashing an element means nullifying its position, folding and unpublishing it.
    def trash!
      self.public = false
      self.folded = true
      self.remove_from_list
    end

    def trashed?
      self.position.nil?
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
      if Page.current_preview == self.page
        "alchemy/elements/#{id}-#{updated_at}"
      else
        "alchemy/elements/#{id}-#{page.published_at}"
      end
    end

    private

    # Returns previous or next public element from same page.
    #
    # @param [String]
    #   Pass '>' or '<' to find next or previous public element.
    # @param [String]
    #   Pass an element name to get previous of this kind.
    #
    def previous_or_next(dir, name = nil)
      elements = page.elements.published.where("#{self.class.table_name}.position #{dir} #{position}")
      elements = elements.named(name) if name.present?
      elements.reorder("position #{dir == '>' ? 'ASC' : 'DESC'}").limit(1).first
    end

    # Returns all cells from given page this element could be placed in.
    #
    def available_page_cells(page)
      page.cells.select do |cell|
        cell.available_elements.include?(self.name)
      end
    end

    # Returns all uniq cell names from given page this element could be placed in.
    #
    def unique_available_page_cell_names(page)
      available_page_cells(page).collect(&:name).uniq
    end

    # If element has a +cell+ associated,
    # it updates it's timestamp.
    #
    # Called after_update
    #
    def touch_cell
      cell.touch
    end
  end
end
