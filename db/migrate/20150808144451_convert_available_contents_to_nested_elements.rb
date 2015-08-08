class ConvertAvailableContentsToNestedElements < ActiveRecord::Migration
  def up
    elements_with_available_contents = Alchemy::Element.all.select do |e|
      e.definition['available_contents']
    end
    elements_with_available_contents.each do |el|
      available_content_names = el.definition['available_contents'].map { |e| e['name'] }
      available_content_names.each do |name|
        contents = el.contents.where(name: name)
        contents.each do |content|
          new_element = Alchemy::Element.new_from_scratch(name: "addable_#{content.name}")
          new_element.contents << content
          new_element.save!
          el.nested_elements << new_element
          el.contents.delete(content)
          el.save
        end
      end
    end
  end
  def down
  end
end
