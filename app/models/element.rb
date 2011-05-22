class Element < ActiveRecord::Base
  require 'yaml'

  acts_as_list :scope => :page_id
  stampable :stamper_class_name => :user
  has_many :contents, :order => :position, :dependent => :destroy
  belongs_to :page
  has_and_belongs_to_many :to_be_sweeped_pages, :class_name => 'Page', :uniq => true
  
  validates_uniqueness_of :position, :scope => :page_id
  validates_presence_of :name, :on => :create, :message => N_("Please choose an element.")
  
  before_destroy :remove_contents
  
  attr_accessor :create_contents_after_create
  after_create :create_contents, :unless => Proc.new { |m| m.create_contents_after_create == false }
  
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
  
  def remove_contents
    self.contents.each do |content|
      content.destroy
    end
  end
  
  def content_by_name(name)
    self.contents.find_by_name(name)
  end

  def content_by_type(essence_type)
    self.contents.find_by_essence_type(essence_type)
  end

  def all_contents_by_name(name)
    self.contents.find_all_by_name(name)
  end

  def all_contents_by_type(essence_type)
    self.contents.find_all_by_essence_type(essence_type)
  end
  
  # Inits a new element for page as described in /config/alchemy/elements.yml from element_name
  def self.new_from_scratch(attributes)
    attributes.stringify_keys!    
    return Element.new if attributes['name'].blank?
    element_descriptions = Element.descriptions
    return if element_descriptions.blank?
    element_scratch = element_descriptions.select{ |m| m["name"] == attributes['name'] }.first
    element_scratch.delete("contents")
    element_scratch.delete("available_contents")
    element = Element.new(
      element_scratch.merge({:page_id => attributes['page_id']})
    )
    element
  end
  
  # Inits a new element for page as described in /config/alchemy/elements.yml from element_name and saves it
  def self.create_from_scratch(attributes)
    element = Element.new_from_scratch(attributes)
    element.save if element
    return element
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
  
  # Returns the array with the hashes for all element contents in the elements.yml file
  def content_descriptions
    return nil if description.blank?
    description['contents']
  end
  
  # Returns the array with the hashes for all element available_contents in the elements.yml file
  def available_content_descriptions
    return nil if description.blank?
    description['available_contents']
  end
  
  # Returns the description for given content_name
  def content_description_for(content_name)
    if content_descriptions.blank?
      logger.warn("\n+++++++++++ Warning: Element #{self.name} is missing the content description for #{content_name}\n")
      return nil
    else
      content_descriptions.detect { |d| d['name'] == content_name }
    end
  end
  
  # Returns the description for given content_name inside the available_contents
  def available_content_description_for(content_name)
    return nil if available_content_descriptions.blank?
    available_content_descriptions.detect { |d| d['name'] == content_name }
  end
  
  # returns the description of the element with my name in element.yml
  def description
    return nil if Element.descriptions.blank?
    Element.descriptions.detect{ |d| d['name'] == self.name }
  end
  
  # Gets the preview text from the first Content found in the +elements.yml+ Element description file.
  # You can flag a Content as +take_me_for_preview+ to take this as preview.
  def preview_text(maxlength = 30)
    return "" if description.blank?
    my_contents = description["contents"]
    return "" if my_contents.blank?
    content_flagged_as_preview = my_contents.select{ |a| a["take_me_for_preview"] }.first
    if content_flagged_as_preview.blank?
      content_to_take_as_preview = my_contents.first
    else
      content_to_take_as_preview = content_flagged_as_preview
    end
    preview_content = self.contents.select{ |content| content.name == content_to_take_as_preview["name"] }.first
    return "" if preview_content.blank? || preview_content.essence.blank?
    text = preview_content.essence.preview_text(maxlength)
    text.size > maxlength ? "#{text[0..maxlength]}..." : text
  end
  
  # Generates a preview text containing Element#display_name and Element#preview_text.
  # It is displayed inside the head of the Element in the Elements.list overlay window from the Alchemy Admin::Page#edit view.
  # 
  # === Example
  # 
  # A Element described as:
  #  
  #     - name: funky_element
  #       display_name: Funky Element
  #       contents:
  #       - name: headline
  #         type: EssenceText
  #       - name: text
  #         type EssenceRichtext
  #         take_me_for_preview: true
  # 
  # With "I want to tell you a funky story" as stripped_body for the EssenceRichtext Content produces:
  # 
  #     Funky Element: I want to tell ...
  #
  # Options:
  # 
  #     maxlength(integer). [Default 30] : Length of characters after the text will be cut off.
  #
  def display_name_with_preview_text(maxlength = 30)
    "#{display_name}: #{preview_text(maxlength)}"
  end
  
  def dom_id
    "#{name}_#{id}"
  end
  
  # List all elements by from page_layout
  def self.list_elements_by_layout(layout = "standard")
    elements = Element.descriptions
    result = []
    page_layouts = Alchemy::PageLayout.get
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
    self.find_by_id(clipboard[:element_id])
  end
  
  def self.all_from_clipboard(clipboard)
    return [] if clipboard.nil?
    self.find_all_by_id(clipboard)
  end
  
  def self.all_from_clipboard_for_page(clipboard, page)
    return [] if clipboard.nil? || page.nil?
    allowed_elements = self.all_for_page(page)
    clipboard_elements = self.all_from_clipboard(clipboard)
    allowed_element_names = allowed_elements.collect { |e| e['name'] }
    clipboard_elements.select { |ce| allowed_element_names.include?(ce.name) }
  end
  
  # returns the collection of available essence_types that can be created for this element depending on its description in elements.yml
  def available_contents
    description['available_contents']
  end
  
  # Returns the contents ingredient for passed content name.
  def ingredient(name)
    content = content_by_name(name)
    return nil if content.blank?
    content.ingredient
  end
  
private
  
  # List all elements by from page_layout
  def self.all_for_page(page)
    element_descriptions = Element.descriptions
    element_names = Alchemy::PageLayout.element_names_for(page.page_layout)
    return [] if element_names.blank?
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
    element = self.create!(attributes.merge(:create_contents_after_create => false, :id => nil))
    source.contents.each do |content|
      new_content = Content.copy(content, :element_id => element.id)
      new_content.move_to_bottom
    end
    element
  end
  
  # creates the contents for this element as described in the elements.yml
  def create_contents
    element_scratch = description
    contents = []
    if element_scratch["contents"].blank?
      logger.warn "\n++++++\nWARNING! Could not find any content descriptions for element: #{self.name}\n++++++++\n"
    else
      element_scratch["contents"].each do |content_hash|
        contents << Content.create_from_scratch(self, content_hash.symbolize_keys)
      end
    end
  end
  
end
