# encoding: UTF-8
module Alchemy
	class Page < ActiveRecord::Base

		RESERVED_URLNAMES = %w(admin messages)

		acts_as_nested_set(:dependent => :destroy)
		stampable

		has_many :folded_pages
		has_many :cells, :dependent => :destroy
		has_many :elements, :dependent => :destroy, :order => :position
		has_and_belongs_to_many :to_be_sweeped_elements, :class_name => 'Alchemy::Element', :uniq => true, :join_table => 'alchemy_elements_alchemy_pages'
		belongs_to :language

		validates_presence_of :name, :message => '^' + I18n.t("please enter a name")
		validates_presence_of :page_layout, :message => '^' + I18n.t("Please choose a page layout."), :unless => :systempage?
		validates_presence_of :parent_id, :message => '^' + I18n.t("No parent page was given."), :if => proc { Page.count > 1 }
		validates_length_of :urlname, :minimum => 3, :too_short => I18n.t("urlname_to_short"), :if => :urlname_entered?
		validates_uniqueness_of :urlname, :message => '^' + I18n.t("URL-Name already token"), :scope => 'language_id', :if => :urlname_entered?
		validates :urlname, :exclusion => { :in => RESERVED_URLNAMES, :message => '^' + I18n.t("This urlname is reserved.") }

		attr_accessor :do_not_autogenerate
		attr_accessor :do_not_sweep
		attr_accessor :do_not_validate_language

		before_save :set_url_name, :unless => proc { |page| page.systempage? || page.redirects_to_external? }
		before_save :set_title, :unless => proc { |page| page.systempage? || page.redirects_to_external? || !page.title.blank? }
		before_save :set_language_code, :unless => :systempage?
		before_save :set_restrictions_to_child_pages, :if => proc { |page| !page.systempage? && page.restricted_changed? }
		before_save :inherit_restricted_status, :if => proc { |page| !page.systempage? && page.parent && page.parent.restricted? }
		after_create :autogenerate_elements, :unless => proc { |page| page.systempage? || page.do_not_autogenerate }
		after_create :create_cells, :unless => :systempage?

		scope :language_roots, where(:language_root => true)
		scope :layoutpages, where(:layoutpage => true)
		scope :all_locked, where(:locked => true)
		scope :all_locked_by, lambda { |user| where(:locked => true, :locked_by => user.id) }
		scope :not_locked, where(:locked => false)
		scope :visible, where(:visible => true)
		scope :published, where(:public => true)
		scope :accessable, where(:restricted => false)
		scope :restricted, where(:restricted => true)
		scope :not_restricted, where(:restricted => false)
		scope :public_language_roots, lambda {
			where(:language_root => true).where("`alchemy_pages`.`language_code` IN ('#{Language.all_codes_for_published.join('\',\'')}')").where(:public => true)
		}
		scope :all_last_edited_from, lambda { |user| where(:updater_id => user.id).order('`alchemy_pages`.`updated_at` DESC').limit(5) }
		# Returns all pages that have the given language_id
		scope :with_language, lambda { |language_id| where(:language_id => language_id) }
		# Returns all pages that are not locked and public.
		# Used for flushing all page caches at once.
		scope :contentpages, where("`alchemy_pages`.`layoutpage` = 0 AND `alchemy_pages`.`parent_id` IS NOT NULL")
		scope :flushables, not_locked.published.contentpages
		scope :searchables, not_restricted.published.contentpages

		# Finds selected elements from page.
		# 
		# Options are:
		# 
		#     :only => Array of element names    # Returns only elements with given names
		#     :except => Array of element names  # Returns all elements except the ones with given names
		#     :count => Integer                  # Limit the count of returned elements
		#     :offset => Integer                 # Starts with an offset while returning elements
		#     :random => Boolean                 # Returning elements randomly shuffled
		#     :from_cell => Cell                 # Returning elements from given cell
		# 
		# Returns only public elements by default.
		# Pass true as second argument to get all elements.
		# 
		def find_selected_elements(options = {}, show_non_public = false)
			if options[:from_cell].class.name == 'Alchemy::Cell'
				elements = options[:from_cell].elements
			else
				elements = self.elements.not_in_cell
			end
			if !options[:only].blank?
				elements = self.elements.named(options[:only])
			elsif !options[:except].blank?
				elements = self.elements.excluded(options[:except])
			end
			elements = elements.offset(options[:offset]).limit(options[:count])
			elements = elements.order("RAND()") if options[:random]
			if show_non_public
				elements
			else
				elements.published
			end
		end

		def find_elements(options = {}, show_non_public = false) #:nodoc:
			# TODO: What is this? A Kind of proxy method? Why not rendering the elements directly if you already have them????
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
			group = ::ActiveSupport::OrderedHash.new
			self.cells.each { |cell| group[cell] = cell.elements.not_trashed }
			if element_names_not_in_cell.any?
				group[Cell.new({:name => 'for_other_elements'})] = elements.not_trashed.not_in_cell
			end
			return group
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
		def previous_page(options = {})
			default_options = {
				:restricted => nil,
				:public => true
			}
			options = default_options.merge(options)
			find_next_or_previous_page("previous", options)
		end

		# Finds the next page on the same structure level. Otherwise it returns nil.
		# Options:
		# => :restricted => boolean (standard: nil) - next restricted page (true), skip restricted pages (false), ignore restriction (nil)
		# => :public => boolean (standard: true) - next public page (true), skip public pages (false)
		def next_page(options = {})
			default_options = {
				:restricted => nil,
				:public => true
			}
			options = default_options.merge(options)
			find_next_or_previous_page("next", options)
		end

		def find_first_public(page)
			if(page.public == true)
				return page
			end
			page.children.each do |child|
				result = find_first_public(child)
				if(result!=nil)
					return result
				end
			end
			return nil
		end

		def name_entered?
			!self.name.blank?
		end

		def urlname_entered?
			!self.urlname.blank?
		end

		def set_url_name
			self.urlname = convert_url_name((self.urlname.blank? ? self.name : self.urlname))
		end

		def set_title
			self.title = self.name
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
			self.elements.select{ |m| m.public? }
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
			folded_page.update_attributes(:folded => status)
			folded_page.save
		end

		def folded?(user_id)
			folded_page = FoldedPage.find_by_user_id_and_page_id(user_id, self.id)
			return false if folded_page.nil?
			folded_page.folded
		end

		def elements_by_type type
			elements.select{|m| type.include? m.name}
		end

		# Returns the translated explanation of seven the page stati.
		# TODO: Let I18n do this!
		def humanized_status
			case self.status
			when 0
				return I18n.t('page_status_visible_public_locked')
			when 1
				return I18n.t('page_status_visible_unpublic_locked')
			when 2
				return I18n.t('page_status_invisible_public_locked')
			when 3
				return I18n.t('page_status_invisible_unpublic_locked')
			when 4
				return I18n.t('page_status_visible_public')
			when 5
				return I18n.t('page_status_visible_unpublic')
			when 6
				return I18n.t('page_status_invisible_public')
			when 7
				return I18n.t('page_status_invisible_unpublic')
			end
		end

		# Returns the status code. Used by humanized_status and the page status icon inside the sitemap rendered by Pages.index.
		def status
			if self.locked
				if self.public? && self.visible?
					return 0
				elsif !self.public? && self.visible?
					return 1
				elsif self.public? && !self.visible?
					return 2
				elsif !self.public? && !self.visible?
					return 3
				end
			else
				if self.public? && self.visible?
					return 4
				elsif !self.public? && self.visible?
					return 5
				elsif self.public? && !self.visible?
					return 6
				elsif !self.public? && !self.visible?
					return 7
				end
			end
		end

		def has_controller?
			!PageLayout.get(self.page_layout).nil? && !PageLayout.get(self.page_layout)["controller"].blank?
		end

		def controller_and_action
			if self.has_controller?
				{:controller => self.layout_description["controller"], :action => self.layout_description["action"]}
			end
		end

		# Returns the self#page_layout description from config/alchemy/page_layouts.yml file.
		def layout_description
			return {} if self.systempage?
			description = PageLayout.get(self.page_layout)
			if description.nil?
				raise "Description could not be found for page layout named #{self.page_layout}. Please check page_layouts.yml file."
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
				child.update_attribute(:restricted, self.restricted?)
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

		def self.language_root_for(language_id)
			self.language_roots.find_by_language_id(language_id)
		end

		# Creates a copy of source (a Page object) and does a copy of all elements depending to source.
		# You can pass any kind of Page#attributes as a difference to source.
		# Notice: It prevents the element auto_generator from running.
		def self.copy(source, differences = {})
			attributes = source.attributes.symbolize_keys.merge(differences)
			attributes.merge!(
				:do_not_autogenerate => true, 
				:do_not_sweep => true, 
				:visible => false,
				:public => false,
				:locked => false,
				:locked_by => nil
			)
			page = self.new(attributes.except(:id, :updated_at, :created_at, :created_id, :updater_id, :lft, :rgt, :depth))
			if page.save
				# copy the page´s cells
				source.cells.each do |cell|
					new_cell = Cell.create(:name => cell.name, :page_id => page.id)
				end
				# copy the page´s elements
				source.elements.each do |element|
					# detect cell for element
					# if cell is nil also pass nil to element.cell_id
					cell = nil
					cell = page.cells.detect{ |c| c.name == element.cell.name } if element.cell
					new_element = Element.copy(element, :page_id => page.id, :cell_id => (cell.blank? ? nil : cell.id))
					new_element.move_to_bottom
				end
				return page
			else
				raise page.errors.full_messages
			end
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

		def self.layout_root_for(language_id)
			where({:parent_id => Page.root.id, :layoutpage => true, :language_id => language_id}).limit(1).first
		end

		def self.find_or_create_layout_root_for(language_id)
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

		def self.all_from_clipboard(clipboard)
			return [] if clipboard.blank?
			self.find_all_by_id(clipboard.collect { |i| i[:id] })
		end

		def self.all_from_clipboard_for_select(clipboard, language_id, layoutpage = false)
			return [] if clipboard.blank?
			clipboard_pages = self.all_from_clipboard(clipboard)
			allowed_page_layouts = Alchemy::PageLayout.selectable_layouts(language_id, layoutpage)
			allowed_page_layout_names = allowed_page_layouts.collect{ |p| p['name'] }
			clipboard_pages.select { |cp| allowed_page_layout_names.include?(cp.page_layout) }
		end

		def copy_children_to(new_parent)
			self.children.each do |child|
				next if child == new_parent
				new_child = Page.copy(child, {
					:language_id => new_parent.language_id,
					:language_code => new_parent.language_code,
					:name => child.name + ' (' + I18n.t('Copy') + ')',
					:urlname => child.redirects_to_external? ? child.urlname : '',
					:title => ''
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

		def self.link_target_options
			options = [
				[I18n.t('default', :scope => :link_target_options), '']
			]
			link_target_options = Config.get(:link_target_options)
			link_target_options.each do |option|
				options << [I18n.t(option, :scope => :link_target_options), option]
			end
			options
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

		def self.rootpage
			self.root
		end

	private

		def find_next_or_previous_page(direction = "next", options = {})
			if direction == "previous"
				step_direction = ["pages.lft < ?", self.lft]
				order_direction = "lft DESC"
			else
				step_direction = ["pages.lft > ?", self.lft]
				order_direction = "lft"
			end
			conditions = Page.merge_conditions(
				{:parent_id => self.parent_id},
				{:public => options[:public]},
				step_direction
			)
			if !options[:restricted].nil?
				conditions = Page.merge_conditions(conditions, {:restricted => options[:restricted]})
			end
			return Page.where(conditions).order(order_direction).limit(1)
		end

		# Converts the given nbame into an url friendly string
		# Names shorter than 3 will be filled with dashes, so it does not collidate with the language code.
		def convert_url_name(name)
			url_name = name.gsub(/[äÄ]/, 'ae').gsub(/[üÜ]/, 'ue').gsub(/[öÖ]/, 'oe').parameterize
			url_name = ('-' * (3 - url_name.length)) + url_name if url_name.length < 3
			return url_name
		end

		# Looks in the layout_descripion, if there are elements to autogenerate.
		# If so, it generates them.
		def autogenerate_elements
			elements = self.layout_description["autogenerate"]
			unless (elements.blank?)
				elements.each do |element|
					element = Element.create_from_scratch({'page_id' => self.id, 'name' => element})
					element.move_to_bottom if element
				end
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

	end
end
