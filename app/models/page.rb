class Page < ActiveRecord::Base
  acts_as_nested_set
  stampable
  has_many :folded_pages
  has_many :elements, :order => :position, :dependent => :destroy
  has_and_belongs_to_many :to_be_sweeped_elements, :class_name => 'Element', :uniq => true
  
  validates_presence_of :name, :message => N_("please enter a name")
  validates_length_of :urlname, :on => :create, :minimum => 3, :too_short => N_("urlname_to_short"), :if => :urlname_entered?
  validates_uniqueness_of :urlname, :message => N_("URL-Name already token"), :scope => 'language', :if => :urlname_entered?
  #validates_format_of :urlname, :with => /http/, :if => Proc.new { |page| page.redirects_to_external? }
  
  attr_accessor :do_not_autogenerate
  attr_accessor :do_not_sweep
  
  before_save :set_url_name, :unless => Proc.new { |page| page.redirects_to_external? }
  after_save :set_restrictions_to_child_pages
  before_validation_on_create :set_url_name, :unless => Proc.new { |page| page.redirects_to_external? }
  before_validation_on_create :set_title
  after_create :autogenerate_elements, :unless => Proc.new { |page| page.do_not_autogenerate }
  
  # necessary. otherwise the migrations fail
  
  def self.layout_root
    if Page.root
      Page.find :first, :conditions => {:parent_id => Page.root.id, :layoutpage => true}
    end
  end
  
  named_scope :language_roots, :conditions => "language_root_for IS NOT NULL"
  
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
    return self.elements.find(:all, :conditions => condition, :limit => options[:count], :order => options[:random].blank? ? nil : "RAND()")
  end
  
  def find_elements(options, show_non_public = false)
    if !options[:collection].blank? && options[:collection].is_a?(Array)
      all_elements = options[:collection]
    else
      all_elements = find_selected_elements(options, show_non_public)
    end
    return all_elements
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
    !PageLayout.get(self.page_layout).nil? && !PageLayout.get(self.page_layout)["controller"].blank?
  end
  
  def controller_and_action
    if self.has_controller?
      {:controller => self.layout_description["controller"], :action => self.layout_description["action"]}
    end
  end
  
  def self.language_root(language)
    find_by_language_root_for(language)
  end
  
  def is_root? language
    Page.language_root( language) == self
  end
  
  def parent_language
    parent = self
    while parent.parent && parent.language_root_for.blank?
      parent = parent.parent
    end
    unless parent.blank?
      parent_lang = parent.language
    else
      parent_lang = self.language
    end
    parent_lang
  end

  def layout_description
    PageLayout.get(self.page_layout)
  end
  
  def layout_display_name
    unless layout_description.blank?
      if layout_description["display_name"].blank?
        return page_layout.camelize
      else
        return layout_description["display_name"]
      end
    end
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
    self.layout_description['feed']
  end
  
  # Returns true or false if the pages layout_description for config/alchemy/page_layouts.yml contains redirects_to_external: true
  def redirects_to_external?
    desc = self.layout_description
    return false if desc.blank?
    desc["redirects_to_external"]
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
    end
    new_url_name
  end
  
  # Look in the layout_descripion, if there are elements to autogenerate. If so, generate them.
  def autogenerate_elements
    to_auto_generate_elements = self.layout_description["autogenerate"]
    unless (to_auto_generate_elements.blank?)
      to_auto_generate_elements.each do |element|
        element = Element.create_from_scratch({'page_id' => self.id, 'name' => element})
        element.move_to_bottom if element
      end
    end
  end

  # Creates a copy of source and a copy of elements from source
  # pass any kind of Page.attributes as a difference to source
  # it also prevents the element auto_generator from running
  def self.copy(source, differences = {})
    attributes = source.attributes.merge(differences)
    attributes.merge!(:do_not_autogenerate => true, :do_not_sweep => true)
    page = self.new(attributes.except("id"))
    if page.save
      source.elements.each do |element|
        new_element = Element.copy(element, :page_id => page.id)
        new_element.move_to_bottom
      end
      return page
    else
      raise "Error while Page.copy: #{page.errors.map{ |e| e[0] + ': ' + e[1] }}"
    end
  end
  
  # Returns all pages for langugae that are not locked and public.
  # Used for flushing all page caches at once.
  def self.flushables(language)
    self.all(:conditions => {:public => true, :locked => false, :language => language})
  end
  
end
