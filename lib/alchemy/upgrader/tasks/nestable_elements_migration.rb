module Alchemy::Upgrader::Tasks
  class NestableElementsMigration
    def migrate_existing_elements
      elements_with_nestable_elements = Alchemy::Element.all.select do |e|
        e.definition['nestable_elements']
      end

      if elements_with_nestable_elements.present?
        elements_with_nestable_elements.each do |el|
          migrate_element(el)
        end
      else
        puts "No elements with `nestable_elements` found. Skip"
      end
    end

    private

    def migrate_element(el)
      orphaned_contents = el.contents.where.not(name: element_content_names(el))

      if orphaned_contents.present?
        orphaned_contents.each do |content|
          next unless addable_element_present_for?(content)
          create_element_for_content(content)
        end
      else
        puts "No orphaned contents found for #{el.dom_id}. Skip"
      end
    end

    def element_content_names(el)
      # names of contents directly defined on element
      content_names = el.definition.fetch('contents', []).collect do |definition|
        definition['name']
      end

      # names of contents defined on elements nestable elements
      nestable_content_names = el.definition['nestable_elements'].collect { |name|
        Alchemy::Element.definition_by_name(name).try(:content_definitions)
      }.compact.collect { |c| c['name'] }.uniq

      # we only want content names that are not defined on nestable elements, so we can move them
      content_names - nestable_content_names
    end

    def create_element_for_content(content)
      parent = content.element

      new_element = Alchemy::Element.create(
        name: "#{parent.name}_#{content.name}",
        parent_element_id: parent.id,
        public: parent.public,
        folded: parent.folded,
        creator: parent.creator,
        updater: parent.updater,
        page: parent.page,
        create_contents_after_create: false
      )

      content.update_columns(element_id: new_element.id)
      puts "Created new element `#{new_element.name}` for content `#{content.name}`"
    end

    def addable_element_present_for?(content)
      Alchemy::Element.definitions.any? do |definition|
        definition['name'] == "#{content.element.name}_#{content.name}"
      end
    end
  end
end
