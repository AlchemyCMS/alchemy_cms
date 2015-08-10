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

        new_element = Alchemy::Element.create(
          name: "addable_#{content.name}",
          parent_element_id: parent.id,
          public: parent.public,
          folded: parent.folded,
          creator: parent.creator,
          updater: parent.updater,
          page: parent.page,
          create_contents_after_create: false
        )

        content.update_columns(element_id: new_element.id)
      end
    end
  end
  def down
    raise ActiveRecord::IrreversibleMigrationError
  end


  private

  def addable_element_present_for?(content_name)
    Alchemy::Element.definitions.any? do |definition|
      definition['name'] == "addable_#{content_name}"
    end
  end
end
