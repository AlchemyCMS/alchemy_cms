class WaPage < ActiveRecord::Base
  acts_as_nested_set
  stampable :stamper_class_name => :wa_user
  has_many :wa_foldeds
  has_many :wa_molecules, :order => :position, :dependent => :destroy
  has_and_belongs_to_many :to_be_sweeped_molecules, :class_name => 'WaMolecule', :uniq => true
  
  validates_presence_of :name, :message => N_("please enter a name")
  validates_length_of :urlname, :on => :create, :minimum => 3, :too_short => N_("urlname_to_short"), :if => :urlname_entered?
  
  # Checking urlname twice, because of downwards compatibility, when WaPage.language was no attribute.
  # Very important for migrating from 0 and for old alchemy installations.
  # Do not remove!
  validates_uniqueness_of(
    :urlname,
    :message => N_("name_already_taken_in_this_language"),
    :scope => :language,
    :if => Proc.new { |page| page.respond_to?(:language) }
  )
  validates_uniqueness_of(
    :urlname,
    :message => N_("name_already_taken"),
    :unless => Proc.new { |page| page.respond_to?(:language) }
  )
  ##
  
  attr_accessor :do_not_autogenerate
  attr_accessor :do_not_sweep
  
  before_save :set_url_name
  after_save :update_depth, :set_restrictions_to_child_pages
  before_validation_on_create :set_url_name, :set_title
  after_create :autogenerate_molecules, :unless => Proc.new { |page| page.do_not_autogenerate }
  before_destroy :check_if_root
  
  # necessary. otherwise the migrations fail
  if WaPage.root
    named_scope :systemroot, :conditions => {:parent_id => WaPage.root.id, :systempage => true}, :limit => 1
  end
  
  named_scope :language_roots, :conditions => "language_root_for IS NOT NULL"
  
  # Finds selected molecules from page either except a passed collection or only the passed collection
  # Collection is an array of strings from molecule names. E.g.: ['text', 'headline']
  # Returns only public ones
  def find_selected_molecules(options, show_non_public = false)
    public_condition = show_non_public ? nil : ' AND wa_molecules.public = 1'
    if !options[:except].blank?
      condition = ["wa_molecules.name NOT IN (?)#{public_condition}", options[:except]]
    elsif !options[:only].blank?
      condition = ["wa_molecules.name IN (?)#{public_condition}", options[:only]]
    else
      condition = show_non_public.nil? ? nil : {:public => true}
    end
    return self.wa_molecules.find(:all, :conditions => condition, :limit => options[:count], :order => options[:random].blank? ? nil : "RAND()")
  end
  
  def find_molecules(options, show_non_public = false)
    if !options[:collection].blank? && options[:collection].is_a?(Array)
      all_molecules = options[:collection]
    else
      all_molecules = find_selected_molecules(options, show_non_public)
    end
    return all_molecules
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
    self.save
  end
  
  def unlock
    self.locked = false
    self.locked_by = nil
    self.do_not_sweep = true
    self.save
  end
  
  def check_if_root
    if self.parent_id.nil?
      raise _("root_page_not_deletable")
      return false
    end
  end
  
  def update_infos(user)
    self.created_by = user.id if self.created_by.nil?
    self.updated_by = user.id
  end

  def public_molecules
    self.wa_molecules.select{ |m| m.public? }
  end
  
  # Returns the name of the creator of this page.
  def creator
    @page_creator ||= WaUser.find_by_id(created_by)
    return _('unknown') if @page_creator.nil?
    @page_creator.name
  end
  
  # Returns the name of the last updater of this page.
  def updater
    @page_updater = WaUser.find_by_id(updated_by)
    return _('unknown') if @page_updater.nil?
    @page_updater.name
  end
  
  # Returns the name of the user currently editing this page.
  def current_editor
    @current_editor = WaUser.find_by_id(locked_by)
    return _('unknown') if @current_editor.nil?
    @current_editor.name
  end
  
  # Returns true if the WaPage is locked for user. So the user cannot edit this page.
  def locked_for(user)
    raise "WaUser is nil" if user.nil?
    locked_by == user.id
  end
  
  def locker
    WaUser.find_by_id(self.locked_by)
  end
  
  def fold(user_id, status)
    wa_folded = WaFolded.find_or_create_by_wa_user_id_and_wa_page_id(user_id, self.id)
    wa_folded.update_attributes(:folded => status)
    wa_folded.save
  end
  
  def folded?(user_id)
    wa_folded = WaFolded.find_by_wa_user_id_and_wa_page_id(user_id, self.id)
    return false if wa_folded.nil?
    wa_folded.folded
  end
  
  def molecules_by_type type
    wa_molecules.select{|m| type.include? m.name}
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

  # Returns the status code. Used by humanized_status and the page status icon inside the sitemap rendered by WaAdmin.index.
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
    !WaPageLayout.get(self.page_layout).nil? && !WaPageLayout.get(self.page_layout)["controller"].blank?
  end
  
  def controller_and_action
    if self.has_controller?
      {:controller => self.layout_description["controller"], :action => self.layout_description["action"]}
    end
  end
  
  def self.language_root(language)
    find_by_language_root_for(language)
  end
  
  # Returns the level reduced by one, because of the WaPage.root.
  # Do we really need this? This is only cosmetically, isn't it?
  def language_level
    depth - 1
  end
  
  def is_root? language
    WaPage.language_root( language) == self
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
    WaPageLayout.get(self.page_layout)
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
  
  def update_depth
    return if !self.respond_to?(:depth)
    unless self.level == self.depth
      self.update_attribute(:depth, self.level)
      self.children.each{ |child| child.update_depth }
    end
  end
  
  def set_restrictions_to_child_pages
    return nil if !defined? self.restricted
    descendants.each do |child|
      child.restricted = restricted
      child.save
    end
  end
  
private

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
  
  # Look in the layout_descripion, if there are molecules to autogenerate. If so, generate them.
  def autogenerate_molecules
    to_auto_generate_molecules = self.layout_description["autogenerate"]
    unless (to_auto_generate_molecules.blank?)
      to_auto_generate_molecules.each do |molecule|
        molecule = WaMolecule.create_from_scratch(self.id, molecule)
        molecule.move_to_bottom
      end
    end
  end

  # Creates a copy of source and a copy of wa_molecules from source
  # pass any kind of WaPage.attributes as a difference to source
  # it also prevents the molecule auto_generator from running
  def self.copy(source, differences = {})
    attributes = source.attributes.merge(differences)
    attributes.merge!(:do_not_autogenerate => true, :do_not_sweep => true)
    wa_page = self.new(attributes.except("id"))
    if wa_page.save
      source.wa_molecules.each do |molecule|
        new_molecule = WaMolecule.copy(molecule, :wa_page_id => wa_page.id)
        new_molecule.move_to_bottom
      end
      return wa_page
    else
      raise "Error while WaPage.copy: #{wa_page.errors.map{ |e| e[0] + ': ' + e[1] }}"
    end
  end

end
