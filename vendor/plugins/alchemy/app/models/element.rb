class Element < ActiveRecord::Base
  require 'yaml'

  acts_as_list :scope => :page_id
  stampable :stamper_class_name => :user
  has_many :contents, :order => :position, :dependent => :destroy
  belongs_to :page
  has_and_belongs_to_many :to_be_sweeped_pages, :class_name => 'Page', :uniq => true

  validates_uniqueness_of :position, :scope => :page_id

  before_destroy :remove_atoms

  attr_accessor :create_atoms_after_create
  after_create :create_atoms, :unless => Proc.new { |m| m.create_atoms_after_create == false }
  
  # Returns next Element on self.page or nil. Pass a Element.name to get next of this kind.
  def next(name = nil)
    if name.nil?
      find_conditions = ["public = 1 AND page_id = ? AND position > ?", self.page.id, self.position]
    else
      find_conditions = ["public = 1 AND page_id = ? AND name = ? AND position > ?", self.page.id, name, self.position]
    end
    self.class.find :first, :conditions => find_conditions, :order => "position ASC"
  end

  # Returns previous Element on self.page or nil. Pass a Element.name to get previous of this kind.
  def prev(name = nil)
    if name.nil?
      find_conditions = ["public = 1 AND page_id = ? AND position < ?", self.page.id, self.position]
    else
      find_conditions = ["public = 1 AND page_id = ? AND name = ? AND position < ?", self.page.id, name, self.position]
    end
    self.class.find :first, :conditions => find_conditions, :order => "position DESC"
  end

  def store_page page
    unless self.to_be_sweeped_pages.include? page
      self.to_be_sweeped_pages << page
      self.save
    end
  end
  
  def remove_atoms
    self.contents.each do |atom|
      atom.destroy
    end
  end
  
  def atom_by_name(name)
    self.contents.find_by_name(name)
  end

  def atom_by_type(atom_type)
    self.contents.find_by_atom_type(atom_type)
  end

  def all_atoms_by_name(name)
    self.contents.find_all_by_name(name)
  end

  def all_atoms_by_type(atom_type)
    self.contents.find_all_by_atom_type(atom_type)
  end
  
  # creates a new element for page as described in /config/alchemy/elements.yml from element_name
  def self.create_from_scratch(page_id, element_name)
    element_scratch = Element.descriptions.select{ |m| m["name"] == element_name }.first
    raise "Could not find element: #{element_name}" if element_scratch.nil?
    element_scratch.delete("contents")
    element_scratch.delete("available_atoms")
    element = Element.new(
      element_scratch.merge({:page_id => page_id})
    )
    element.save!
    element
  end
  
  # pastes a element from the clipboard in the session to page
  def self.paste_from_clipboard(page_id, element, method, position)
    copy = self.copy(element, :page_id => page_id)
    copy.insert_at(position)
    if method == "move" && copy.valid?
      element.destroy
    end
    copy
  end

  def self.descriptions
    if File.exists? "#{RAILS_ROOT}/config/alchemy/elements.yml"
      @elements = YAML.load_file( "#{RAILS_ROOT}/config/alchemy/elements.yml" )
    elsif File.exists? "#{RAILS_ROOT}/vendor/plugins/alchemy/config/alchemy/elements.yml"
      @elements = YAML.load_file( "#{RAILS_ROOT}/vendor/plugins/alchemy/config/alchemy/elements.yml" )
    else
      raise "Could not read config/alchemy/elements.yml"
    end
  end
  
  # Selects the atom in the element.yml description that is flagged as take_me_for_preview or takes the first atom if only one atom exists for element.
  # Then selects the atom from the element that is equivalent to this flagged atom to display its contect as preview text for element editor
  def preview_text
    text = ""
    begin
      my_contents = my_description["contents"]
      unless my_contents.blank?
        atom_flagged_as_preview = my_contents.select{ |a| a["take_me_for_preview"] }.first
        if atom_flagged_as_preview.blank?
          atom_to_take_as_preview = my_contents.first
        else
          atom_to_take_as_preview = atom_flagged_as_preview
        end
        preview_atom = self.contents.select{ |atom| atom.name == atom_to_take_as_preview["name"] }.first
        unless preview_atom.blank?
          if preview_atom.atom_type == "EssenceRichtext"
            text = preview_atom.atom.stripped_content.to_s
          elsif preview_atom.atom_type == "EssenceText"
            text = preview_atom.atom.content.to_s
          elsif preview_atom.atom_type == "EssencePicture"
            text = (preview_atom.atom.image.name rescue "")
          elsif preview_atom.atom_type == "EssenceFile" || preview_atom.atom_type == "EssenceFlash" || preview_atom.atom_type == "EssenceFlashvideo"
            text = (preview_atom.atom.file.name rescue "")
          else
            text = ""
          end
        else
          text = ""
        end
      end
    rescue
      logger.error("#{$!}\n#{$@.join('\n')}")
      text = ""
    end
    text.size > 30 ? text = (text[0..30] + "...") : text
    text
  end
  
  def display_name_with_preview_text
    display_name + ": " + preview_text
  end
  
  def dom_id
    "#{name}_#{id}"
  end
  
  # List all elements by from page_layout
  def self.list_elements_by_layout(layout = "standard")
    elements = Element.descriptions
    result = []
    page_layouts = PageLayout.get
    layout_elements = page_layouts.select{|p| p["name"] == layout}.first["elements"]
    return elements if layout_elements == "all"
    elements.each do |element|
      if layout_elements.include? element["name"]
        result << element
      end
    end
    return result
  end
  
  def self.get_from_clipboard(clipboard)
    return nil if clipboard.blank?
    self.find(clipboard[:element_id])
  end
  
  # returns the collection of available atom_types that can be created for this element depending on its description in elements.yml
  def available_atoms
    my_description['available_atoms']
  end
  
  # returns the description of the element with my name in element.yml
  def my_description
    Element.descriptions.detect{ |d| d["name"] == self.name }
  end
  
private
  
  # List all elements by from page_layout
  def self.all_for_layout(page, page_layout = "standard")
    element_descriptions = Element.descriptions
    element_names = PageLayout.element_names_for(page_layout)
    return element_descriptions if element_names == "all"
    elements_for_layout = []
    for element_description in element_descriptions do
      if element_names.include?(element_description["name"])# TODO: && unique and not already on page
        elements_for_layout << element_description
      end
    end
    
    #TODO: refactor this and place as condition in the above collect
    # all unique elements from this layout
    unique_elements = elements_for_layout.select{ |m| m["unique"] == true }
    elements_already_on_the_page = page.elements
    # delete all elements from the elements that could be placed that are unique and already and the page
    unique_elements.each do |unique_element|
      elements_already_on_the_page.each do |already_placed_element|
        if already_placed_element.name == unique_element["name"]
          elements_for_layout.delete(unique_element)
        end
      end
    end
    
    return elements_for_layout
  end
  
  # makes a copy of source and makes copies of the contents from source
  def self.copy(source, differences = {})
    differences[:position] = nil
    attributes = source.attributes.except("id").merge(differences)
    element = self.create!(attributes.merge(:create_atoms_after_create => false, :id => nil))
    source.contents.each do |content|
      new_atom = Content.copy(content, :element_id => element.id)
      new_atom.move_to_bottom
    end
    element
  end
  
  # creates the atoms for this element as described in the elements.yml
  def create_atoms
    element_scratch = my_description
    atoms = []
    if element_scratch["contents"].blank?
      logger.warn "\n++++++\nWARNING! Could not find any atom descriptions for element: #{self.name}\n++++++++\n"
    else
      element_scratch["contents"].each do |atom_hash|
        atoms << Content.create_from_scratch(self, atom_hash.symbolize_keys, {:created_from_element => true})
      end
    end
  end
  
end
