class Element < ActiveRecord::Base
  
  # All Elements inside a cell are a list. All Elements not in cell are in the cell_id.nil list.
  acts_as_list :scope => [:page_id, :cell_id]
  stampable :stamper_class_name => :user
  
  has_many :contents, :order => :position, :dependent => :destroy
  belongs_to :cell
  belongs_to :page
  has_and_belongs_to_many :to_be_sweeped_pages, :class_name => 'Page', :uniq => true
  
  validates_uniqueness_of :position, :scope => [:page_id, :cell_id]
  validates_presence_of :name, :on => :create, :message => N_("Please choose an element.")
  
  attr_accessor :create_contents_after_create
  after_create :create_contents, :unless => Proc.new { |m| m.create_contents_after_create == false }
  
  # TODO: add a trashed column to elements table
  named_scope :trashed, :conditions => {:page_id => nil}, :order => 'updated_at DESC'
  
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
  
  # nullifies the page_id aka. trashs it.
  def trash
    self.page_id = nil
    self.folded = true
    self.save(false)
  end
  
  def trashed?
    page_id.nil?
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
    element = Element.new(
      element_scratch.except('contents', 'available_contents', 'display_name').merge({
        :page_id => attributes['page_id']
      })
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
  
  def self.definitions
    self.descriptions
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
  
  # Human name for displaying in selectboxes and element editor views.
  # The name is beeing translated from elements name value as described in config/alchemy/elements.yml
  # 
  # Translate the name in your config/locales language file. Example:
  # 
  #   de:
  #     element_names:
  #       contactform: 'Kontakt Formular'
  # 
  # If no translation is found the capitalized name is used!
  # 
  def display_name
    return name.capitalize if description.blank?
    I18n.t("alchemy.element_names.#{description['name']}", :default => name.capitalize)
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
  def self.elements_for_layout(layout)
    element_descriptions = Element.descriptions
    elements = []
    page_layout = Alchemy::PageLayout.get(layout)
    layout_elements = page_layout["elements"]
    return element_descriptions if layout_elements == "all"
    element_descriptions.each do |element|
      if layout_elements.include?(element["name"])
        elements << element
      end
    end
    return elements
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
  
  def save_contents(params)
    contents.each do |content|
      unless content.save_essence(params[:contents]["content_#{content.id}"], :public => !params["public"].nil?)
        errors.add(:base, :essence_validation_failed)
      end
    end
    return errors.blank?
  end
  
  def essences
    return [] if contents.blank?
    contents.collect(&:essence)
  end
  
  # Returns all essence_errors in the format:
  # 
  #   {
  #     essence.content.name => [error_message_for_validation_1, error_message_for_validation_2]
  #   }
  # 
  # Get translated error messages with Element#essence_error_messages
  #
  def essence_errors
    essence_errors = {}
    essences.each do |essence|
      unless essence.essence_errors.blank?
        essence_errors[essence.content.name] = essence.essence_errors
      end
    end
    essence_errors
  end
  
  # Essence validation errors messages are translated via I18n.
  # Inside your translation file add translations like:
  # 
  #   alchemy:
  #     content_validations:
  #       name_of_the_element:
  #         name_of_the_content:
  #           validation_error_type: Error Message
  # 
  # validation_error_type has to be one of:
  # 
  # * blank
  # * taken
  # * wrong_format
  # 
  # Example:
  # 
  #   de:
  #     alchemy:
  #       content_validations:
  #         contact:
  #           email:
  #             wrong_format: 'Die Email hat nicht das richtige Format'
  # 
  def essence_error_messages
    messages = []
    essence_errors.each do |content_name, errors|
      errors.each do |error|
        messages << I18n.t(
          "alchemy.content_validations.#{self.name}.#{content_name}.#{error}",
          :default => [
            "alchemy.content_validations.fields.#{content_name}.#{error}".to_sym,
            "alchemy.content_validations.errors.#{error}".to_sym
          ]
        ) % {:field => Content.translated_label_for(content_name)}
      end
    end
    messages
  end
  
  def contents_with_errors
    contents.select(&:essence_validation_failed?)
  end
  
  def has_validations?
    !contents.detect(&:has_validations?).blank?
  end
  
  def rtf_contents
    contents.select { |content| content.essence_type == 'EssenceRichtext' }
  end
  
  # The name of the cell the element could be placed in.
  def belonging_cellname
    cellname = Cell.name_for_element(name)
    if cellname.blank?
      return 'for_other_elements' 
    else
      return cellname
    end
  end
  
private
  
  # List all elements for page_layout
  def self.all_for_page(page)
    # if page_layout has cells, collect elements from cells and group them by cellname
    page_layout = Alchemy::PageLayout.get(page.page_layout)
    if page_layout.blank?
      logger.warn "\n++++++\nWARNING! Could not find page_layout description for page: #{page.name}\n++++++++\n"
      return []
    end
    elements_for_layout = []
    if page_layout['cells'].is_a?(Array)
      elements_for_layout += Cell.all_element_definitions_for(page_layout['cells'])
    end
    elements_for_layout += all_definitions_for(page_layout['elements'])
    return [] if elements_for_layout.blank?
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
  
  def self.all_definitions_for(element_names)
    if element_names.to_s == "all"
      return element_descriptions
    else
      return definitions.select { |e| element_names.include? e['name'] }
    end
  end
  
  # makes a copy of source and makes copies of the contents from source
  def self.copy(source, differences = {})
    attributes = source.attributes.except("id").merge(differences)
    element = self.create!(attributes.merge(:create_contents_after_create => false, :id => nil, :position => nil))
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
