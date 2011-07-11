class Page < ActiveRecord::Base
  
  acts_as_nested_set
  stampable
  
  has_many :folded_pages
  has_many :cells, :dependent => :destroy
  has_many :elements, :dependent => :destroy, :order => :position
  has_and_belongs_to_many :to_be_sweeped_elements, :class_name => 'Element', :uniq => true
  belongs_to :language
  
  validates_presence_of :name, :message => N_("please enter a name")
  validates_presence_of :page_layout, :message => N_("Please choose a page layout.")
  validates_length_of :urlname, :minimum => 3, :too_short => N_("urlname_to_short"), :if => :urlname_entered?
  validates_uniqueness_of :urlname, :message => N_("URL-Name already token"), :scope => 'language_id', :if => :urlname_entered?
  
  attr_accessor :do_not_autogenerate
  attr_accessor :do_not_sweep
  attr_accessor :do_not_validate_language
  
  before_save :set_url_name, :unless => Proc.new { |page| page.redirects_to_external? }
  before_save :set_title, :unless => Proc.new { |page| page.redirects_to_external? }
  before_save :set_language_code
  after_create :autogenerate_elements, :unless => Proc.new { |page| page.do_not_autogenerate }
  after_create :create_cells
  after_save :set_restrictions_to_child_pages
  
  named_scope :language_roots, :conditions => {:language_root => true}
  named_scope :layoutpages, :conditions => {:layoutpage => true}
  named_scope :all_locked, :conditions => {:locked => true}
  named_scope :contentpages, :conditions => "pages.layoutpage = 0 AND pages.parent_id IS NOT NULL"
  
  # Finds selected elements from page either except a passed collection or only the passed collection
  # Collection is an array of strings from element names. E.g.: ['text', 'headline']
  # Returns only public ones
  def find_selected_elements(options, show_non_public = false)
    public_condition = show_non_public ? nil : ' AND elements.public = 1'
    if !options[:except].blank?
      condition = ["elements.name NOT IN (?)#{public_condition}", options[:except]]
    elsif !options[:only].blank?
      condition = ["elements.name IN (?)#{public_condition}", options[:only]]
    else
      condition = show_non_public.nil? ? nil : {:public => true}
    end
    return self.elements.find(:all, :conditions => condition, :limit => options[:count], :offset => options[:offset], :order => options[:random].blank? ? nil : "RAND()")
  end
  
  def find_elements(options, show_non_public = false)
    if !options[:collection].blank? && options[:collection].is_a?(Array)
      all_elements = options[:collection]
    else
      all_elements = find_selected_elements(options, show_non_public)
    end
    return all_elements
  end
  
  def elements_grouped_by_cells
    group = ActiveSupport::OrderedHash.new
    cells.each { |cell| group[cell] = cell.elements }
    group[Cell.new({:name => 'for_other_elements'})] = elements.find_all_by_cell_id(nil)
    return group
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
    self.urlname = generate_url_name((self.urlname.blank? ? self.name : self.urlname))
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
    self.save(false)
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
    return _('unknown') if @page_creator.nil?
    @page_creator.name
  end
  
  # Returns the name of the last updater of this page.
  def updater
    @page_updater = User.find_by_id(updater_id)
    return _('unknown') if @page_updater.nil?
    @page_updater.name
  end
  
  # Returns the name of the user currently editing this page.
  def current_editor
    @current_editor = User.find_by_id(locked_by)
    return _('unknown') if @current_editor.nil?
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
  def humanized_status
    case self.status
    when 0
      then
      return _('page_status_visible_public_locked')
    when 1
      then
      return _('page_status_visible_unpublic_locked')
    when 2
      then
      return _('page_status_invisible_public_locked')
    when 3
      then
      return _('page_status_invisible_unpublic_locked')
    when 4
      then
      return _('page_status_visible_public')
    when 5
      then
      return _('page_status_visible_unpublic')
    when 6
      then
      return _('page_status_invisible_public')
    when 7
      then
      return _('page_status_invisible_unpublic')
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
    !Alchemy::PageLayout.get(self.page_layout).nil? && !Alchemy::PageLayout.get(self.page_layout)["controller"].blank?
  end
  
  def controller_and_action
    if self.has_controller?
      {:controller => self.layout_description["controller"], :action => self.layout_description["action"]}
    end
  end
  
  # Returns the self#page_layout description from config/alchemy/page_layouts.yml file.
  def layout_description
    page_layout = Alchemy::PageLayout.get(self.page_layout)
    if page_layout.nil?
      logger.warn("\n+++++++++++  Warning! PageLayout description not found for layout: #{self.page_layout}\n")
      return nil
    else
      return page_layout
    end
  end
  alias_method :definition, :layout_description
  
  # Returns translated name of the pages page_layout value.
  # Page layout names are defined inside the config/alchemy/page_layouts.yml file.
  # Translate the name in your config/locales language yml file.
  def layout_display_name
    I18n.t("alchemy.page_layout_names.#{page_layout}", :default => page_layout.camelize)
  end
  
  def renamed?
    self.name_was != self.name || self.urlname_was != self.urlname
  end
  
  def changed_publicity?
    self.public_was != self.public
  end
  
  def set_restrictions_to_child_pages
    return nil if self.restricted_was == self.restricted
    descendants.each do |child|
      child.restricted = restricted
      child.save
    end
  end
  
  def contains_feed?
    desc = self.layout_description
    return false if desc.blank?
    desc["feed"]
  end
  
  # Returns true or false if the pages layout_description for config/alchemy/page_layouts.yml contains redirects_to_external: true
  def redirects_to_external?
    desc = self.layout_description
    return false if desc.blank?
    desc["redirects_to_external"]
  end
  
  # Returns an array of all pages currently locked by user
  def self.all_locked_by(user)
    find_all_by_locked_and_locked_by(true, user.id)
  end
  
  def self.public_language_roots
    public_language_codes = Language.all_codes_for_published
    all(:conditions => "language_root = 1 AND language_code IN ('#{public_language_codes.join('\',\'')}') AND public = 1")
  end
  
  def first_public_child
    self.children.detect{ |child| child.public? }
  end
  
  def self.language_root_for(language_id)
    self.language_roots.find_by_language_id(language_id)
  end
  
  # Creates a copy of source (an Page object) and does a copy of all elements depending to source.
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
    page = self.new(attributes.except(["id", "updated_at", "created_at", "created_id", "updater_id"]))
    if page.save
      source.elements.each do |element|
        new_element = Element.copy(element, :page_id => page.id)
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
    find(:first, :conditions => {:parent_id => Page.root.id, :layoutpage => true, :language_id => language_id})
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
    if layoutroot.save(false)
      layoutroot.move_to_child_of(Page.root)
      return layoutroot
    else
      raise "Layout root for #{language.name} could not be created"
    end
  end
  
  def self.all_last_edited_from(user)
    Page.all(:conditions => {:updater_id => user.id}, :order => "updated_at DESC", :limit => 5)
  end
  
  def self.all_from_clipboard(clipboard)
    return [] if clipboard.blank?
    self.find_all_by_id(clipboard)
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
        :name => child.name + ' (' + _('Copy') + ')',
        :urlname => '',
        :title => ''
      })
      new_child.move_to_child_of(new_parent)
      child.copy_children_to(new_child) unless child.children.blank?
    end
  end
  
  # Returns true or false if the page has a page_layout that has cells.
  def has_cells?
    pagelayout = Alchemy::PageLayout.get(self.page_layout)
    return false if pagelayout.blank?
    !pagelayout['cells'].blank?
  end
  
  def self.link_target_options
    options = [
      [I18n.t('default', :scope => 'alchemy.link_target_options'), '']
    ]
    link_target_options = Alchemy::Configuration.get(:link_target_options)
    link_target_options.each do |option|
      options << [I18n.t(option, :scope => 'alchemy.link_target_options'), option]
    end
    options
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
    return Page.find :first, :conditions => conditions, :order => order_direction
  end
  
  def generate_url_name(url_name)
    new_url_name = url_name.to_s.downcase
    new_url_name = new_url_name.gsub(/[ä]/, 'ae')
    new_url_name = new_url_name.gsub(/[ü]/, 'ue')
    new_url_name = new_url_name.gsub(/[ö]/, 'oe')
    new_url_name = new_url_name.gsub(/[Ä]/, 'AE')
    new_url_name = new_url_name.gsub(/[Ü]/, 'UE')
    new_url_name = new_url_name.gsub(/[Ö]/, 'OE')
    new_url_name = new_url_name.gsub(/[ß]/, 'ss')
    new_url_name = new_url_name.gsub(/[^a-zA-Z0-9_]+/, '-')
    if(new_url_name.length < 3)
      new_url_name = "-#{new_url_name}-"
    else
      new_url_name.gsub(/-+$/, '')
    end
  end
  
  # Looks in the layout_descripion, if there are elements to autogenerate.
  # If so, it generates them.
  def autogenerate_elements
		return true if self.layout_description.blank?
    elements = self.layout_description["autogenerate"]
    unless (elements.blank?)
      elements.each do |element|
        element = Element.create_from_scratch({'page_id' => self.id, 'name' => element})
        element.move_to_bottom if element
      end
    end
  end
  
  # Returns all pages for langugae that are not locked and public.
  # Used for flushing all page caches at once.
  def self.flushables(language_id)
    self.all(:conditions => {:public => true, :locked => false, :language_id => language_id})
  end
  
  def set_language_code
    return false if self.language.blank?
    self.language_code = self.language.code
  end
  
  def create_cells
    return true if !has_cells?
    definition['cells'].each do |cellname|
      cells.create({:name => cellname})
    end
  end
  
end
