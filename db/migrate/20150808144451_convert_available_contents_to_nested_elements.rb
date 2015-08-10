class ConvertAvailableContentsToNestedElements < ActiveRecord::Migration
  def up
    elements_with_nestable_elements = Alchemy::Element.all.select do |e|
      e.definition['nestable_elements']
    end

    elements_with_nestable_elements.each do |el|
      element_contents = el.definition['contents'].inject([]) do |content_names, definition|
        content_names << definition['name']
      end

      orphaned_contents = el.contents.where.not(name: content_names)

      orphaned_contents.each do |content|
        parent = content.element
        new_element = content.element.dup
        new_element.update(name: "addable_#{content.name}")
        content.element = new_element
        new_element.save
        parent.nested_elements << new_element
      end
    end
  end
  def down
  end
end
