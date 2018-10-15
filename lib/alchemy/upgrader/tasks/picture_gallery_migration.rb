module Alchemy
  class Upgrader::Tasks::PictureGalleryMigration
    def migrate_picture_galleries
      if picture_gallery_elements.present?
        picture_gallery_elements.each do |el|
          migrate_element(el)
        end
      else
        puts "No `picture_gallery` elements found. Skip"
      end
    end

    private

    def picture_gallery_elements
      Element.distinct.joins(:contents).where("#{Content.table_name}.name LIKE 'essence_picture_%'")
    end

    def migrate_element(element)
      gallery_contents = element.contents.where("#{Content.table_name}.name LIKE 'essence_picture_%'").order("#{Content.table_name}.position ASC")

      if gallery_contents.any?
        if element.nestable_elements.any?
          parent = create_gallery_element(element)
        else
          parent = element
        end
        gallery_contents.each do |content|
          create_element_for_content(content, parent)
        end
      else
        puts "No gallery contents found for #{element.dom_id}. Skip"
      end
    end

    def create_gallery_element(parent)
      new_element = parent.nested_elements.create!(
        name: "#{parent.name}_picture_gallery",
        public: parent.public,
        folded: parent.folded,
        creator: parent.creator,
        updater: parent.updater,
        page: parent.page,
        create_contents_after_create: false
      )
      puts "Created new `#{new_element.name}` for `#{parent.name}`"
      new_element
    end

    def create_element_for_content(content, parent)
      new_element = parent.nested_elements.create!(
        name: "#{parent.name}_picture",
        public: parent.public,
        folded: parent.folded,
        creator: parent.creator,
        updater: parent.updater,
        page: parent.page,
        create_contents_after_create: false
      )

      content.update_columns(element_id: new_element.id, name: 'picture')
      puts "Created new `#{new_element.name}` for `#{parent.name}`"
    end
  end
end
