# == Schema Information
#
# Table name: alchemy_pages
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  urlname          :string(255)
#  title            :string(255)
#  language_code    :string(255)
#  language_root    :boolean
#  page_layout      :string(255)
#  meta_keywords    :text
#  meta_description :text
#  lft              :integer
#  rgt              :integer
#  parent_id        :integer
#  depth            :integer
#  visible          :boolean          default(FALSE)
#  public           :boolean          default(FALSE)
#  locked           :boolean          default(FALSE)
#  locked_by        :integer
#  restricted       :boolean          default(FALSE)
#  robot_index      :boolean          default(TRUE)
#  robot_follow     :boolean          default(TRUE)
#  sitemap          :boolean          default(TRUE)
#  layoutpage       :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  creator_id       :integer
#  updater_id       :integer
#  language_id      :integer
#  cached_tag_list  :text
#  published_at     :datetime
#

module Alchemy
  class Page < ActiveRecord::Base
    include Alchemy::Hints
    include Alchemy::Logger
    include Alchemy::Touching

    DEFAULT_ATTRIBUTES_FOR_COPY = {
      do_not_autogenerate: true,
      public:              false,
      locked:              false,
      locked_by:           nil
    }
    SKIPPED_ATTRIBUTES_ON_COPY = %w(id updated_at created_at creator_id updater_id lft rgt depth urlname cached_tag_list)
    PERMITTED_ATTRIBUTES = [
      :create_node,
      :language_id,
      :meta_description,
      :meta_keywords,
      :name,
      :page_layout,
      :public,
      :restricted,
      :robot_index,
      :robot_follow,
      :tag_list,
      :title,
      :urlname,
      :parent_id
    ]

    attr_accessor :create_node

    acts_as_taggable

    stampable stamper_class_name: Alchemy.user_class_name

    is_alchemy_node

    belongs_to :language
    belongs_to :parent, class_name: 'Alchemy::Page'
    has_many :nodes, as: :navigatable
    has_many :legacy_urls, class_name: 'Alchemy::LegacyPageUrl'
    has_many :children, class_name: 'Alchemy::Page', foreign_key: 'parent_id'

    validates :language,
      presence: true,
      on: 'create'
    validates :page_layout,
      presence: true,
      format: {
        with: /\A[a-z0-9_-]+\z/,
        if: -> { page_layout.present? }
      }

    attr_accessor :do_not_validate_language

    before_save :set_language_code,
      if: -> { language.present? }
    before_save :update_childrens_restricted_status,
      if: :restricted_changed?
    before_save :inherit_restricted_status,
      if: -> { parent && parent.restricted? }
    before_save :update_published_at,
      if: -> { public && read_attribute(:published_at).nil? }
    before_create :set_language_from_parent_or_default,
      if: -> { language_id.blank? }
    after_update :create_legacy_url,
      if: :urlname_changed?

    after_create :create_node!, if: -> { self.create_node }

    # Concerns
    include Alchemy::Page::PageScopes
    include Alchemy::Page::PageNatures
    include Alchemy::Page::PageNaming
    include Alchemy::Page::PageUsers
    include Alchemy::Page::PageCells
    include Alchemy::Page::PageElements

    # Class methods
    #
    class << self

      # alias_method :rootpage, :root

      # Used to store the current page previewed in the edit page template.
      #
      def current_preview=(page)
        RequestStore.store[:alchemy_current_preview] = page
      end

      # Returns the current page previewed in the edit page template.
      #
      def current_preview
        RequestStore.store[:alchemy_current_preview]
      end

      # Creates a copy of given source.
      #
      # Also copies all elements included in source.
      #
      # === Note:
      #
      # It prevents the element auto generator from running.
      #
      # @param source [Alchemy::Page]
      #   The source page the copy is taken from
      # @param differences [Hash]
      #   A optional hash with attributes that take precedence over the source attributes
      #
      # @return [Alchemy::Page]
      #
      def copy(source, differences = {})
        page = Alchemy::Page.new(attributes_from_source_for_copy(source, differences))
        page.tag_list = source.tag_list
        if page.save!
          copy_cells(source, page)
          copy_elements(source, page)
          page
        end
      end

      def copy_and_paste(source, new_parent, new_name)
        page = copy(source, {
          parent_id: new_parent.id,
          language: new_parent.language,
          name: new_name,
          title: new_name
        })
        if source.children.any?
          source.copy_children_to(page)
        end
        return page
      end

      def all_from_clipboard(clipboard)
        return [] if clipboard.blank?
        where(id: clipboard.collect { |p| p['id'] })
      end

      def all_from_clipboard_for_select(clipboard, language_id, layoutpage = false)
        return [] if clipboard.blank?
        clipboard_pages = self.all_from_clipboard(clipboard)
        allowed_page_layouts = Alchemy::PageLayout.selectable_layouts(language_id, layoutpage)
        allowed_page_layout_names = allowed_page_layouts.collect { |p| p['name'] }
        clipboard_pages.select { |cp| allowed_page_layout_names.include?(cp.page_layout) }
      end

      def link_target_options
        options = [[I18n.t(:default, scope: 'link_target_options'), '']]
        link_target_options = Config.get(:link_target_options)
        link_target_options.each do |option|
          options << [I18n.t(option, scope: 'link_target_options', default: option.to_s.humanize), option]
        end
        options
      end

      # Returns an array of all pages in the same branch from current.
      # I.e. used to find the active page in navigation.
      def ancestors_for(current)
        return [] if current.nil?
        current.self_and_ancestors.contentpages
      end

      # All pages from current language for node select
      def alchemy_navigatables
        with_language(Language.current.id).order(:name)
      end

      # Create page from given node
      def create_from_alchemy_node(node)
        self.create!(
          name: node.name,
          language: node.language,
          page_layout: 'standard' # TODO: find a way to choose page layout
        )
      end

      private

      # Aggregates the attributes from given source for copy of page.
      #
      # @param [Alchemy::Page]
      #   The source page
      # @param [Hash]
      #   A optional hash with attributes that take precedence over the source attributes
      #
      def attributes_from_source_for_copy(source, differences = {})
        source.attributes.stringify_keys!
        differences.stringify_keys!
        attributes = source.attributes.merge(differences)
        attributes.merge!(DEFAULT_ATTRIBUTES_FOR_COPY)
        attributes.merge!('name' => new_name_for_copy(differences['name'], source.name))
        attributes.except(*SKIPPED_ATTRIBUTES_ON_COPY)
      end

      # Returns a new name for copy of page.
      #
      # If the differences hash includes a new name this is taken.
      # Otherwise +source.name+
      #
      # @param [String]
      #   The differences hash that contains a new name
      # @param [String]
      #   The name of the source
      #
      def new_name_for_copy(custom_name, source_name)
        return custom_name if custom_name.present?
        "#{source_name} (#{I18n.t('Copy')})"
      end

    end

    # Instance methods
    #

    # The page's view partial is dependent from its page layout
    #
    # == Define page layouts
    #
    # Page layouts are defined in the +config/alchemy/page_layouts.yml+ file
    #
    #     - name: contact
    #       elements: [contactform]
    #       ...
    #
    # == Override the view
    #
    # Page layout partials live in +app/views/alchemy/page_layouts+
    #
    def to_partial_path
      "alchemy/page_layouts/#{layout_partial_name}"
    end

    # TODO: Delegate Page#previous to node
    # # Returns the previous page on the same level or nil.
    # #
    # # For options @see #next_or_previous
    # #
    # def previous(options = {})
    #   next_or_previous('<', options)
    # end
    # alias_method :previous_page, :previous

    # TODO: Delegate Page#next to node
    # # Returns the next page on the same level or nil.
    # #
    # # For options @see #next_or_previous
    # #
    # def next(options = {})
    #   next_or_previous('>', options)
    # end
    # alias_method :next_page, :next

    # Locks the page to given user without updating the timestamps
    #
    def lock_to!(user)
      self.update_columns(locked: true, locked_by: user.id)
    end

    # Unlocks the page without updating the timestamps
    #
    def unlock!
      if self.update_columns(locked: false, locked_by: nil)
        Page.current_preview = nil
      end
    end

    # TODO: How to handle page copy?
    # def copy_children_to(new_parent)
    #   self.children.each do |child|
    #     next if child == new_parent
    #     new_child = Page.copy(child, {
    #       :language_id => new_parent.language_id,
    #       :language_code => new_parent.language_code
    #     })
    #     new_child.move_to_child_of(new_parent)
    #     child.copy_children_to(new_child) unless child.children.blank?
    #   end
    # end

    # Publishes the page.
    #
    # Sets +public+ to true and the +published_at+ value to current time.
    #
    # The +published_at+ attribute is used as +cache_key+.
    #
    def publish!
      update_columns(published_at: Time.now, public: true)
    end

    # TODO: move to Node
    #
    # Updates an Alchemy::Page based on a new ordering to be applied to it
    #
    # Note: Page's urls should not be updated (and a legacy URL created) if nesting is OFF
    # or if a page is external or if the URL is the same
    #
    # @param [TreeNode]
    #   A tree node with new lft, rgt, depth, url, parent_id and restricted indexes to be updated
    #
    # def update_node!(node)
    #   hash = {lft: node.left, rgt: node.right, parent_id: node.parent, depth: node.depth, restricted: node.restricted}
    #
    #   if !self.redirects_to_external? && self.urlname != node.url
    #     LegacyPageUrl.create(page_id: self.id, urlname: self.urlname)
    #     hash.merge!(urlname: node.url)
    #   end
    #
    #   update_columns(hash)
    # end

    # Returns the url for menu node
    def alchemy_node_url
      read_attribute(:urlname)
    end

    # The url of the pages's parent
    def parent_urlname
      parent.try(:urlname)
    end

    # Return the first node this page is attached at or nil
    def node
      nodes.first
    end

    # If the page has a parent it returns the node of it
    def parent_node
      parent.try(:node)
    end

    # Recursily get all parents
    # TODO: Implement this as a single SQL query
    def parents
      @parents ||= begin
        arr = []
        par = self.parent
        while par do
          arr << par
          par = par.parent
        end
        arr
      end
    end

    private

    # TODO: Delegate to node
    # Returns the next or previous page on the same level or nil.
    #
    # @param [String]
    #   Pass '>' for next and '<' for previous page.
    #
    # @option options [Boolean] :restricted (nil)
    #   only restricted pages (true), skip restricted pages (false)
    # @option options [Boolean] :public (true)
    #   only public pages (true), skip public pages (false)
    #
    # def next_or_previous(dir = '>', options = {})
    #   if self.node.nil?
    #     raise "#{self.name} has no node! Please attach page to a node in order to get next or previous page."
    #   end

    #   options = {
    #     restricted: false,
    #     public: true
    #   }.update(options)

    #   node = self.node.self_and_siblings
    #     .where(["alchemy_nodes.lft #{dir} ?", self.node.lft])
    #     .where(alchemy_pages: {public: options[:public]})
    #     .where(alchemy_pages: {restricted: options[:restricted]})
    #     .reorder(dir == '>' ? 'lft' : 'lft DESC')
    #     .limit(1).first

    #   node.navigatable
    # end

    # Called from before_save if restricted changes
    def update_childrens_restricted_status
      children.each do |child|
        # we need to use update here, because we want the callbacks of children be triggered,
        # so that all children's children get updated as well
        child.update!(restricted: !!self.restricted?)
      end
    end

    # Called from before_save if parent is restricted
    def inherit_restricted_status
      write_attribute(:restricted, !!parent.try(:restricted?))
    end

    def set_language_from_parent_or_default
      self.language = self.parent.language || Language.default
      set_language_code
    end

    def set_language_code
      self.language_code = self.language.code
    end

    # Stores the old urlname in a LegacyPageUrl
    def create_legacy_url
      legacy_urls.find_or_create_by(urlname: urlname_was)
    end

    def update_published_at
      self.published_at = Time.now
    end

    # Creates a node for this page
    #
    # If the page has a parent and the parent a node then the node will placed as child of parents node
    # Otherwise the node gets attached as child of root level
    #
    def create_node!
      node = Node.create!(name: self.name, navigatable: self, language: self.language)
      if parent_node
        node.move_to_child_of(parent_node)
      else
        node.move_to_child_of(Node.root)
      end
    end
  end
end
