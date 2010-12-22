class Content < ActiveRecord::Base
  
  belongs_to :essence, :polymorphic => true, :dependent => :destroy
  belongs_to :element
  stampable :stamper_class_name => :user
  acts_as_list
  
  def scope_condition
    "element_id = '#{element_id}' AND essence_type = '#{essence_type}'"
  end
  
  validates_uniqueness_of :position, :scope => [:element_id, :essence_type]
  
  # Creates a new Content as descriped in the elements.yml file
  def self.create_from_scratch(element, essences_hash, options = {})
    options = {:created_from_element => false}.merge(options)
    if essences_hash[:name].blank? && !essences_hash[:essence_type].blank?
      essences_of_same_type = element.contents.find_all_by_essence_type(essences_hash[:essence_type])
      description = {
        'type' => essences_hash[:essence_type],
        'name' => "#{essences_hash[:essence_type].underscore}_#{essences_of_same_type.length + 1}"
      }
    else
      description = Content.description_for(
        element,
        essences_hash[:name],
        :from_available_essences => !options[:created_from_element]
      )
    end
    raise "No description found in elements.yml for #{essences_hash.inspect} and #{element.inspect}" if description.blank?
    essence_class = ObjectSpace.const_get(description['type'])
    content = self.new(:name => description['name'], :element_id => element.id)
    if description['type'] == "EssenceRichtext" || description['type'] == "EssenceText"
      essence = essence_class.create(:do_not_index => !description['do_not_index'].nil?)
    else
      essence = essence_class.create
    end
    if essence
      content.essence = essence
      content.save
    else
      content = nil
    end
    return content
  end
  
  # Settings from the elements.yml definition
  def settings()
    description = description()
    #if description.blank? && 
    #  description = description(:from_available_essences => true)
    #end
    return nil if description.blank?
    settings = description['settings']
    return nil if settings.blank?
    settings.symbolize_keys
  end
  
  # makes a copy of source and copies the polymorphic associated essence
  def self.copy(source, differences = {})
    differences[:position] = nil
    differences[:id] = nil
    attributes = source.attributes.merge(differences)
    content = self.create!(attributes.except("id"))
    new_essence = content.essence.clone
    new_essence.save
    content.essence_id = new_essence.id
    content
  end
  
  # Returns my description hash from elements.yml
  def description
    Content.description_for(self.element, self.name, options)
  end
  
  # Calls the ingredient method on the essence
  def ingredient
    return nil if self.essence.blank?
    self.essence.ingredient
  end
  
private
  
  # Returns the array with the hashes for all available contents for element in the elements.yml file
  def self.available_essences_for(element)
    element.description['available_contents']
  end
  
  # Returns the array with the hashes for all contents for element in the elements.yml file
  def self.contents_for(element)
    if !element.description.blank?
      return element.description['contents']
    else
      return nil
    end
  end
  
  # Returns the hash for essence_name in element of elements.yml, either from contents array, or from available_essences array.
  # Options: from_available_essences (default false) detects the hash from the available_essences array if set to true
  def self.description_for(element, essence_name, options={})
    options = {:from_available_essences => false}.merge(options)
    if options[:from_available_essences]
      essences = self.available_essences_for(element)
    else
      essences = self.contents_for(element)
    end
    essences.detect{ |d| d['name'] == essence_name } if essences
  end
  
end
