module Alchemy
  class Page < ActiveRecord::Base
    include NameConversions

    RESERVED_URLNAMES = %w(admin messages new)
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
    has_many :cells, :dependent => :destroy
    has_many :elements, :order => :position
    has_many :contents, :through => :elements
    has_many :legacy_urls, :class_name => 'Alchemy::LegacyPageUrl'
    has_and_belongs_to_many :to_be_sweeped_elements, :class_name => 'Alchemy::Element', :uniq => true, :join_table => 'alchemy_elements_alchemy_pages'
    belongs_to :language

    validates_presence_of :language, :on => :create, :unless => :root
    validates_presence_of :name
    validates_presence_of :page_layout, :unless => :systempage?
    validates_presence_of :parent_id, :if => proc { Page.count > 1 }
    validates_length_of :urlname, :minimum => 3, :if => :urlname_entered?
    validates_uniqueness_of :urlname, :scope => [:language_id, :layoutpage], :if => :urlname_entered?
    validates :urlname, :exclusion => {:in => RESERVED_URLNAMES}

    attr_accessor :do_not_autogenerate
    attr_accessor :do_not_sweep
    attr_accessor :do_not_validate_language

    before_validation :set_urlname, :unless => proc { |page| page.systempage? || page.redirects_to_external? }
    before_save :set_title, :unless => proc { |page| page.systempage? || page.redirects_to_external? || !page.title.blank? }
    before_save :set_language_code, :unless => :systempage?
    before_save :set_restrictions_to_child_pages, :if => proc { |page| !page.systempage? && page.restricted_changed? }
    before_save :inherit_restricted_status, :if => proc { |page| !page.systempage? && page.parent && page.parent.restricted? }
    after_create :create_cells, :unless => :systempage?
    after_create :autogenerate_elements, :unless => proc { |page| page.systempage? || page.do_not_autogenerate }
    after_update :trash_not_allowed_elements, :if => :page_layout_changed?
    after_update :autogenerate_elements, :if => :page_layout_changed?
    after_update :create_legacy_url, :if => proc { |page| page.urlname_changed? && !page.redirects_to_external? }
    after_destroy { elements.each {|el| el.destroy unless el.trashed? } }

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

      # Copy page cells
      #
      # @param source [Alchemy::Page]
      # @param target [Alchemy::Page]
      # @return [Array]
      #
      def copy_cells(source, target)
        new_cells = []
        source.cells.each do |cell|
          new_cells << Cell.create(:name => cell.name, :page_id => target.id)
        end
        new_cells
      end

      # Copy page elements
      #
      # @param source [Alchemy::Page]
      # @param target [Alchemy::Page]
      # @return [Array]
      #
      def copy_elements(source, target)
        new_elements = []
        source.elements.not_trashed.each do |element|
          # detect cell for element
          if element.cell
            cell = target.cells.detect { |c| c.name == element.cell.name }
          else
            cell = nil
          end
          # if cell is nil also pass nil to element.cell_id
          new_element = Element.copy(element, :page_id => target.id, :cell_id => (cell.blank? ? nil : cell.id))
          # move element to bottom of the list
          new_element.move_to_bottom
          new_elements << new_element
        end
        new_elements
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
        options = [
          [I18n.t('default', :scope => :link_target_options), '']
        ]
        link_target_options = Config.get(:link_target_options)
        link_target_options.each do |option|
          options << [I18n.t(option, :scope => :link_target_options), option]
        end
        options
      end

    end

    # Instance methods
    #

    # Finds selected elements from page.
    #
    # Returns only public elements by default.
    # Pass true as second argument to get all elements.
    #
    # === Options are:
    #
    #     :only => Array of element names    # Returns only elements with given names
    #     :except => Array of element names  # Returns all elements except the ones with given names
    #     :count => Integer                  # Limit the count of returned elements
    #     :offset => Integer                 # Starts with an offset while returning elements
    #     :random => Boolean                 # Return elements randomly shuffled
    #     :from_cell => Cell or String       # Return elements from given cell
    #
    def find_selected_elements(options = {}, show_non_public = false)
      if options[:from_cell].class.name == 'Alchemy::Cell'
        elements = options[:from_cell].elements
      elsif !options[:from_cell].blank? && options[:from_cell].class.name == 'String'
        cell = cells.find_by_name(options[:from_cell])
        if cell
          elements = cell.elements
        else
          warn("Cell with name `#{options[:from_cell]}` could not be found!")
          # Returns an empty relation. Can be removed with the release of Rails 4
          elements = self.elements.where('1 = 0')
        end
      else
        elements = self.elements.not_in_cell
      end
      if !options[:only].blank?
        elements = elements.named(options[:only])
      elsif !options[:except].blank?
        elements = elements.excluded(options[:except])
      end
      elements = elements.reverse_order if options[:reverse_sort] || options[:reverse]
      elements = elements.offset(options[:offset]).limit(options[:count])
      elements = elements.order("RAND()") if options[:random]
      show_non_public ? elements : elements.published
    end

    # What is this? A Kind of proxy method? Why not rendering the elements directly if you already have them????
    def find_elements(options = {}, show_non_public = false)
      if !options[:collection].blank? && options[:collection].is_a?(Array)
        return options[:collection]
      else
        find_selected_elements(options, show_non_public)
      end
    end

    # Returns all elements that should be feeded via rss.
    #
    # Define feedable elements in your +page_layouts.yml+:
    #
    #   - name: news
    #     feed: true
    #     feed_elements: [element_name, element_2_name]
    #
    def feed_elements
      elements.find_all_by_name(definition['feed_elements'])
    end

    def elements_grouped_by_cells
      elements.not_trashed.in_cell.group_by(&:cell)
    end

    def element_names_from_cells
      cell_definitions.collect { |c| c['elements'] }.flatten.uniq
    end

    def element_names_not_in_cell
      layout_description['elements'].uniq - element_names_from_cells
    end

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

    def name_entered?
      !self.name.blank?
    end

    def urlname_entered?
      !self.urlname.blank?
    end

    def show_in_navigation?
      if visible?
        return true
      end
      return false
    end

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

    def public_elements
      self.elements.select { |m| m.public? }
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

    def elements_by_type type
      elements.select { |m| type.include? m.name }
    end

    # Returns a Hash of attributes describing the status of the Page.
    #
    def status
      combined_status = {}
      combined_status[:visible] = self.visible?
      combined_status[:public] = self.public?
      combined_status[:locked] = self.locked?
      combined_status[:restricted] = self.restricted?
      return combined_status
    end

    # Returns the translated status for given status type.
    #
    # @param [Symbol] status_type
    #
    def status_title(status_type)
      I18n.t(self.send(status_type), :scope => "page_states.#{status_type}")
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

    def cell_definitions
      cell_names = self.layout_description['cells']
      return [] if cell_names.blank?
      Cell.all_definitions_for(cell_names)
    end

    # Returns translated name of the pages page_layout value.
    # Page layout names are defined inside the config/alchemy/page_layouts.yml file.
    # Translate the name in your config/locales language yml file.
    def layout_display_name
      I18n.t(self.page_layout, :scope => :page_layout_names)
    end

    def renamed?
      self.name_was != self.name || self.urlname_was != self.urlname
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

    def contains_feed?
      definition["feed"]
    end

    # Returns true or false if the pages layout_description for config/alchemy/page_layouts.yml contains redirects_to_external: true
    def redirects_to_external?
      definition["redirects_to_external"]
    end

    def first_public_child
      self.children.where(:public => true).limit(1).first
    end

    # Gets the language_root page for page
    def get_language_root
      return self if self.language_root
      page = self
      while page.parent do
        page = page.parent
        break if page.language_root?
      end
      return page
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

    # Returns true or false if the page has a page_layout that has cells.
    def can_have_cells?
      !definition['cells'].blank?
    end

    def has_cells?
      cells.any?
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

    # Overwrites the cache_key method so it uses the published_at attribute instead of updated_at.
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

    def set_urlname
      self.urlname = convert_url_name((self.urlname.blank? ? self.name : self.urlname))
    end

    def set_title
      self.title = self.name
    end

    # Converts the given name into an url friendly string.
    #
    # Names shorter than 3 will be filled up with dashes,
    # so it does not collidate with the language code.
    #
    def convert_url_name(name)
      url_name = convert_to_urlname(name)
      if url_name.length < 3
        ('-' * (3 - url_name.length)) + url_name
      else
        url_name
      end
    end

    # Looks in the page_layout descripion, if there are elements to autogenerate.
    #
    # And if so, it generates them.
    #
    # If the page has cells, it looks if there are elements to generate.
    #
    def autogenerate_elements
      elements_already_on_page = self.elements.available.collect(&:name)
      elements = self.layout_description["autogenerate"]
      if elements.present?
        elements.each do |element|
          next if elements_already_on_page.include?(element)
          Element.create_from_scratch(attributes_for_element_name(element))
        end
      end
    end

    # Returns a hash of attributes for given element name
    def attributes_for_element_name(element)
      if self.has_cells? && (cell_definition = cell_definitions.detect { |c| c['elements'].include?(element) })
        cell = self.cells.find_by_name(cell_definition['name'])
        if cell
          return {:page_id => self.id, :cell_id => cell.id, :name => element}
        else
          raise "Cell not found for page #{self.inspect}"
        end
      else
        return {:page_id => self.id, :name => element}
      end
    end

    def set_language_code
      return false if self.language.blank?
      self.language_code = self.language.code
    end

    def create_cells
      return false if !can_have_cells?
      definition['cells'].each do |cellname|
        cells.create({:name => cellname})
      end
    end

    # Trashes all elements that are not allowed for this page_layout.
    def trash_not_allowed_elements
      elements.select { |e| !definition['elements'].include?(e.name) }.map(&:trash)
    end

    # Stores the old urlname in a LegacyPageUrl
    def create_legacy_url
      legacy_url = legacy_urls.new(:urlname => urlname_was)
      legacy_url.save!
    end

  end
end
