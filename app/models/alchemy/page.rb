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

    stampable(:stamper_class_name => 'Alchemy::User')

    has_many :folded_pages
    has_many :legacy_urls, :class_name => 'Alchemy::LegacyPageUrl'
    belongs_to :language

    validates_presence_of :language, :on => :create, :unless => :root
    validates_presence_of :page_layout, :unless => :systempage?
    validates_presence_of :parent_id, :if => proc { Page.count > 1 }

    attr_accessor :do_not_sweep
    attr_accessor :do_not_validate_language

    before_save :set_language_code, :unless => :systempage?
    before_save :inherit_restricted_status, if: -> { parent && parent.restricted? }, unless: :systempage?
    after_update :set_restrictions_to_child_pages, unless: :systempage?
    after_update :create_legacy_url, :if => :urlname_changed?, :unless => :redirects_to_external?

    scope :language_roots, where(:language_root => true)
    scope :layoutpages, where(:layoutpage => true)
    scope :all_locked, where(:locked => true)
    scope :all_locked_by, lambda { |user| where(:locked => true, :locked_by => user.id) }
    scope :not_locked, where(:locked => false)
    scope :visible, where(:visible => true)
    scope :published, where(:public => true)
    scope :not_restricted, where(:restricted => false)
    scope :restricted, where(:restricted => true)
    scope :public_language_roots, lambda {
      where(:language_root => true, :language_code => Language.all_codes_for_published, :public => true)
    }
    scope :all_last_edited_from, lambda { |user| where(:updater_id => user.id).order('updated_at DESC').limit(5) }
    # Returns all pages that have the given language_id
    scope :with_language, lambda { |language_id| where(:language_id => language_id) }
    scope :contentpages, where(:layoutpage => [false, nil]).where(Page.arel_table[:parent_id].not_eq(nil))
    # Returns all pages that are not locked and public.
    # Used for flushing all page caches at once.
    scope :flushables, not_locked.published.contentpages
    scope :searchables, not_restricted.published.contentpages
    # Scope for only the pages from Alchemy::Site.current
    scope :from_current_site, lambda { where(:alchemy_languages => {site_id: Site.current || Site.default}).joins(:language) }
    # TODO: add this as default_scope
    #default_scope { from_current_site }

    # Concerns
    include Naming
    include Cells
    include Elements

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

      # Creates a copy of source
      #
      # Also copies all elements included in source.
      #
      # === Note:
      # It prevents the element auto generator from running.
      #
      # @param source [Alchemy::Page]
      # @param differences [Hash]
      #
      # @return [Alchemy::Page]
      #
      def copy(source, differences = {})
        source.attributes.stringify_keys!
        differences.stringify_keys!
        attributes = source.attributes.merge(differences)
        attributes.merge!(DEFAULT_ATTRIBUTES_FOR_COPY)
        new_name = differences['name'].present? ? differences['name'] : "#{source.name} (#{I18n.t('Copy')})"
        attributes.merge!('name' => new_name)
        page = self.new(attributes.except(*SKIPPED_ATTRIBUTES_ON_COPY))
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

    end

    # Instance methods
    #

    # Finds the previous page on the same structure level. Otherwise it returns nil.
    # Options:
    # => :restricted => boolean (standard: nil) - next restricted page (true), skip restricted pages (false), ignore restriction (nil)
    # => :public => boolean (standard: true) - next public page (true), skip public pages (false)
    def previous(options = {})
      next_or_previous(:previous, {
        :restricted => nil,
        :public => true
      }.merge(options))
    end
    alias_method :previous_page, :previous

    # Finds the next page on the same structure level. Otherwise it returns nil.
    # Options:
    # => :restricted => boolean (standard: nil) - next restricted page (true), skip restricted pages (false), ignore restriction (nil)
    # => :public => boolean (standard: true) - next public page (true), skip public pages (false)
    def next(options = {})
      next_or_previous(:next, {
        :restricted => nil,
        :public => true
      }.merge(options))
    end
    alias_method :next_page, :next

    def lock(user)
      self.locked = true
      self.locked_by = user.id
      self.save(:validate => false)
    end

    def unlock
      self.locked = false
      self.locked_by = nil
      self.do_not_sweep = true
      self.save
    end

    # Returns the name of the creator of this page.
    def creator
      @page_creator ||= User.find_by_id(creator_id)
      return I18n.t('unknown') if @page_creator.nil?
      @page_creator.name
    end

    # Returns the name of the last updater of this page.
    def updater
      @page_updater = User.find_by_id(updater_id)
      return I18n.t('unknown') if @page_updater.nil?
      @page_updater.name
    end

    # Returns the name of the user currently editing this page.
    def current_editor
      @current_editor = User.find_by_id(locked_by)
      return I18n.t('unknown') if @current_editor.nil?
      @current_editor.name
    end

    def locker
      User.find_by_id(self.locked_by)
    end

    def fold(user_id, status)
      folded_page = FoldedPage.find_or_create_by_user_id_and_page_id(user_id, self.id)
      folded_page.folded = status
      folded_page.save
    end

    def folded?(user_id)
      folded_page = FoldedPage.find_by_user_id_and_page_id(user_id, self.id)
      return false if folded_page.nil?
      folded_page.folded
    end

    # Returns a Hash describing the status of the Page.
    #
    def status
      {
        visible: visible?,
        public: public?,
        locked: locked?,
        restricted: restricted?
      }
    end

    # Returns the translated status for given status type.
    #
    # @param [Symbol] status_type
    #
    def status_title(status_type)
      I18n.t(self.status[status_type].to_s, scope: "page_states.#{status_type}")
    end

    def has_controller?
      !PageLayout.get(self.page_layout).nil? && !PageLayout.get(self.page_layout)["controller"].blank?
    end

    def controller_and_action
      if self.has_controller?
        controller = self.layout_description["controller"].gsub(/^([^\/])/, "/#{$1}")
        {:controller => controller, :action => self.layout_description["action"]}
      end
    end

    # Returns the self#page_layout description from config/alchemy/page_layouts.yml file.
    def layout_description
      return {} if self.systempage?
      description = PageLayout.get(self.page_layout)
      if description.nil?
        raise PageLayoutDefinitionError, "Description could not be found for page layout named #{self.page_layout}. Please check page_layouts.yml file."
      else
        description
      end
    end
    alias_method :definition, :layout_description

    # Returns translated name of the pages page_layout value.
    # Page layout names are defined inside the config/alchemy/page_layouts.yml file.
    # Translate the name in your config/locales language yml file.
    def layout_display_name
      I18n.t(self.page_layout, :scope => :page_layout_names)
    end

    def changed_publicity?
      self.public_was != self.public
    end

    # Sets my restricted value to all child pages
    #
    def set_restrictions_to_child_pages
      descendants.update_all(restricted: self.restricted?)
    end

    def contains_feed?
      definition["feed"]
    end

    # Returns true or false if the pages layout_description for config/alchemy/page_layouts.yml contains redirects_to_external: true
    def redirects_to_external?
      !!definition["redirects_to_external"]
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

    def locker_name
      return I18n.t('unknown') if self.locker.nil?
      self.locker.name
    end

    def rootpage?
      !self.new_record? && self.parent_id.blank?
    end

    def systempage?
      return true if Page.root.nil?
      rootpage? || (self.parent_id == Page.root.id && !self.language_root?)
    end

    # Overwrites the cache_key method.
    def cache_key(request = nil)
      "alchemy/pages/#{id}"
    end

    def taggable?
      definition['taggable'] == true
    end

    # Publishes the page
    #
    # Sets public true and saves the object.
    def publish!
      self.public = true
      self.save
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

    def next_or_previous(direction = :next, options = {})
      pages = self.class.scoped
      if direction == :previous
        step_direction = ["#{self.class.table_name}.lft < ?", self.lft]
        order_direction = "lft DESC"
      else
        step_direction = ["#{self.class.table_name}.lft > ?", self.lft]
        order_direction = "lft"
      end
      pages = pages.where(:public => options[:public])
      pages = pages.where(:parent_id => self.parent_id)
      pages = pages.where(step_direction)
      if !options[:restricted].nil?
        pages = pages.where(:restricted => options[:restricted])
      end
      pages.order(order_direction).limit(1).first
    end

    def set_language_code
      return false if self.language.blank?
      self.language_code = self.language.code
    end

    # Stores the old urlname in a LegacyPageUrl
    def create_legacy_url
      legacy_urls.find_or_create_by_urlname(:urlname => urlname_was)
    end

    # Sets my restricted status to parent's restricted status
    #
    def inherit_restricted_status
      self.restricted = parent.restricted?
    end

  end
end
