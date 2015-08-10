# This migration comes from alchemy (originally 20150808144451)
class ConvertAvailableContentsToNestedElements < ActiveRecord::Migration
  def up
    elements_with_nestable_elements = Alchemy::Element.all.select do |e|
      e.definition['nestable_elements']
    end

    elements_with_nestable_elements.each do |el|
      element_content_names = if el.definition['contents'].blank?
        []
      else
        el.definition['contents'].inject([]) do |content_names, definition|
          content_names << definition['name']
        end
      end

      orphaned_contents = el.contents.where.not(name: element_content_names)

      orphaned_contents.each do |content|
        next unless addable_element_present_for?(content.name)

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


  private

  def addable_element_present_for?(content_name)
    Alchemy::Element.definitions.any? do |definition|
      definition['name'] == "addable_#{content_name}"
    end
  end
end
