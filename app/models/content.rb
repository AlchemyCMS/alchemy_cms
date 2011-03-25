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
  def self.create_from_scratch(element, essences_hash)
    if essences_hash[:name].blank? && !essences_hash[:essence_type].blank?
      essences_of_same_type = element.contents.find_all_by_essence_type(essences_hash[:essence_type])
      description = {
        'type' => essences_hash[:essence_type],
        'name' => "#{essences_hash[:essence_type].underscore}_#{essences_of_same_type.length + 1}"
      }
    else
      description = element.content_description_for(essences_hash[:name])
      description = element.available_content_description_for(essences_hash[:name]) if description.blank?
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
  def settings
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
  # Returns the description from available_contents if my own description is blank
  def description
    if self.element.blank?
      logger.warn("\n+++++++++++ Warning: Content with id #{self.id} is missing its Element\n")
      return nil
    else
      desc = self.element.content_description_for(self.name)
      if desc.blank?
        desc = self.element.available_content_description_for(self.name)
      else
        return desc
      end
    end
  end
  
  # Gets the ingredient from essence
  def ingredient
    return nil if self.essence.blank?
    self.essence.ingredient
  end
  
  # Calls essence.save_ingredient. Called from ElementController#update for each content in element.
  # Adding errors if essence validation fails.
  def save_essence(params, options = {})
    if essence.save_ingredient(params, options)
      return true
    else
      errors.add(:base, :essence_validation_failed)
      return false
    end
  end
  
  def essence_validation_failed?
    !essence.essence_errors.blank?
  end
  
  def has_validations?
    return false if description.blank?
    !description['validate'].blank?
  end
  
end
