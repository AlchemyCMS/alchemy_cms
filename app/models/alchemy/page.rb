require 'acts-as-taggable-on'
require 'awesome_nested_set'

module Alchemy
  class Page < ActiveRecord::Base

    DEFAULT_ATTRIBUTES_FOR_COPY = {
      :do_not_autogenerate => true,
      :do_not_sweep => true,
      :visible => false,
      :public => false,
      :locked => false,
      :locked_by => nil
    }
    SKIPPED_ATTRIBUTES_ON_COPY = %w(id updated_at created_at creator_id updater_id lft rgt depth urlname cached_tag_list)

    attr_accessible(
      :do_not_autogenerate,
      :do_not_sweep,
      :language_code,
      :language,
      :language_id,
      :language_root,
      :layoutpage,
      :locked,
      :locked_by,
      :meta_description,
      :meta_keywords,
      :name,
      :page_layout,
      :parent_id,
      :public,
      :restricted,
      :robot_index,
      :robot_follow,
      :sitemap,
      :tag_list,
      :title,
      :urlname,
      :visible
    )

    acts_as_taggable
    acts_as_nested_set(:dependent => :destroy)

    stampable stamper_class_name: Alchemy.user_class_name

    has_many :folded_pages

    has_many :legacy_urls, :class_name => 'Alchemy::LegacyPageUrl'
    belongs_to :language
    belongs_to :locker, class_name: Alchemy.user_class_name, foreign_key: 'locked_by'

    validates_presence_of :language, :on => :create, :unless => :root
    validates_presence_of :page_layout, :unless => :systempage?
    validates_presence_of :parent_id, :if => proc { Page.count > 1 }

    attr_accessor :do_not_sweep
    attr_accessor :do_not_validate_language

    before_save :set_language_code, :unless => :systempage?
    before_save :set_restrictions_to_child_pages, :if => :restricted_changed?, :unless => :systempage?
    before_save :inherit_restricted_status, :if => proc { parent && parent.restricted? }, :unless => :systempage?
    after_update :create_legacy_url, :if => :urlname_changed?, :unless => :redirects_to_external?

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

      alias_method :rootpage, :root

      # @return the language root page for given language id.
      # @param language_id [Fixnum]
      #
      def language_root_for(language_id)
        self.language_roots.find_by_language_id(language_id)
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

      def layout_root_for(language_id)
        where({:parent_id => Page.root.id, :layoutpage => true, :language_id => language_id}).limit(1).first
      end

      def find_or_create_layout_root_for(language_id)
        layoutroot = layout_root_for(language_id)
        return layoutroot if layoutroot
        language = Language.find(language_id)
        layoutroot = Page.new({
          :name => "Layoutroot for #{language.name}",
          :layoutpage => true,
          :language => language,
          :do_not_autogenerate => true
        })
        if layoutroot.save(:validate => false)
          layoutroot.move_to_child_of(Page.root)
          return layoutroot
        else
          raise "Layout root for #{language.name} could not be created"
        end
      end

      def paste_from_clipboard(source, new_parent, new_name)
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
        self.find_all_by_id(clipboard.collect { |i| i[:id] })
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

    # Touches the timestamps and userstamps
    def touch
      update_hash = {updated_at: Time.now}
      update_hash[:updater_id] = Alchemy.user_class.stamper if Alchemy.user_class.respond_to?(:stamper)
      Page.where(id: self.id).update_all(update_hash)
    end

    # Returns the previous page on the same level or nil.
    #
    # For options @see #next_or_previous
    #
    def previous(options = {})
      next_or_previous('<', options)
    end
    alias_method :previous_page, :previous

    # Returns the next page on the same level or nil.
    #
    # For options @see #next_or_previous
    #
    def next(options = {})
      next_or_previous('>', options)
    end
    alias_method :next_page, :next

    # Locks the page to given user without updating the timestamps
    #
    def lock!(user)
      # Yes, since +update_columns+ is not available in Rails 3.2,
      # we use this workaround to update straight in the db.
      Page.where(id: self.id).update_all(locked: true, locked_by: user.id)
    end

    # Unlocks the page without updating the timestamps
    #
    def unlock!
      # Yes, since +update_columns+ is not available in Rails 3.2,
      # we use this workaround to update straight in the db.
      Page.where(id: self.id).update_all(locked: false, locked_by: nil)
    end

    def fold!(user_id, status)
      folded_page = folded_pages.find_or_create_by_user_id(user_id)
      folded_page.folded = status
      folded_page.save
    end

    def changed_publicity?
      self.public_was != self.public
    end

    def set_restrictions_to_child_pages
      descendants.each do |child|
        child.update_attributes(:restricted => self.restricted?)
      end
    end

    def inherit_restricted_status
      self.restricted = parent.restricted?
    end

    # Returns the first published child
    def first_public_child
      children.published.first
    end

    # Gets the language_root page for page
    def get_language_root
      self_and_ancestors.where(:language_root => true).first
    end

    def copy_children_to(new_parent)
      self.children.each do |child|
        next if child == new_parent
        new_child = Page.copy(child, {
          :language_id => new_parent.language_id,
          :language_code => new_parent.language_code
        })
        new_child.move_to_child_of(new_parent)
        child.copy_children_to(new_child) unless child.children.blank?
      end
    end

    # Publishes the page
    #
    # Sets public true and saves the object.
    def publish!
      self.public = true
      self.save
    end

    def set_language_from_parent_or_default_language
      self.language = self.parent.language || Language.get_default
      set_language_code
    end

    # Updates an Alchemy::Page based on a new ordering to be applied to it
    #
    # Note: Page's urls should not be updated (and a legacy URL created) if nesting is OFF
    # or if a page is external or if the URL is the same
    #
    # @param [TreeNode]
    #   A tree node with new lft, rgt, depth, url, parent_id and restricted indexes to be updated
    #
    def update_node!(node)
      hash = {lft: node.left, rgt: node.right, parent_id: node.parent, depth: node.depth, restricted: node.restricted}

      if Config.get(:url_nesting) && !self.redirects_to_external? && self.urlname != node.url
        LegacyPageUrl.create(page_id: self.id, urlname: self.urlname)
        hash.merge!(urlname: node.url)
      end

      self.class.update_all(hash, {id: self.id})
    end

  private

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
    def next_or_previous(dir = '>', options = {})
      options = {
        restricted: false,
        public: true
      }.update(options)

      self_and_siblings
        .where(["#{self.class.table_name}.lft #{dir} ?", lft])
        .where(public: options[:public])
        .where(restricted: options[:restricted])
        .order(dir == '>' ? 'lft' : 'lft DESC')
        .limit(1).first
    end

    def set_language_code
      return false if self.language.blank?
      self.language_code = self.language.code
    end

    # Stores the old urlname in a LegacyPageUrl
    def create_legacy_url
      legacy_urls.find_or_create_by_urlname(:urlname => urlname_was)
    end

  end
end
