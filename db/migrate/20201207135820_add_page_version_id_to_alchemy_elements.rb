# frozen_string_literal: true

class AddPageVersionIdToAlchemyElements < ActiveRecord::Migration[5.2]
  class LocalPage < ActiveRecord::Base
    self.table_name = :alchemy_pages
    has_many :elements, class_name: "LocalElement", inverse_of: :page
    has_many :versions, class_name: "LocalVersion", inverse_of: :page, foreign_key: :page_id
  end

  class LocalVersion < ActiveRecord::Base
    self.table_name = :alchemy_page_versions
    belongs_to :page, class_name: "LocalPage", inverse_of: :versions
    has_many :elements, class_name: "LocalElement", inverse_of: :versions
  end

  class LocalElement < ActiveRecord::Base
    self.table_name = :alchemy_elements
    belongs_to :page, class_name: "LocalPage", inverse_of: :elements
    belongs_to :page_version, class_name: "LocalVersion", inverse_of: :elements
  end

  def change
    add_reference :alchemy_elements, :page_version,
                  index: false,
                  foreign_key: {
                    to_table: :alchemy_page_versions,
                    on_delete: :cascade,
                  }
    add_index :alchemy_elements, [:page_version_id, :parent_element_id],
              name: "idx_alchemy_elements_on_page_version_id_and_parent_element_id"
    add_index :alchemy_elements, [:page_version_id, :position],
              name: "idx_alchemy_elements_on_page_version_id_and_position"

    # Add a page version for each page so we can add a not null constraint
    reversible do |dir|
      dir.up do
        say_with_time "Create draft version for each page." do
          LocalPage.find_each do |page|
            next if page.versions.any?

            page.versions.create!.tap do |version|
              Alchemy::Element.where(page_id: page.id).update_all(page_version_id: version.id)
            end
          end
          LocalVersion.count
        end
      end
    end

    change_column_null :alchemy_elements, :page_version_id, false

    # Remove the existing page relation
    remove_reference :alchemy_elements, :page,
                     null: false,
                     index: false,
                     foreign_key: {
                       to_table: :alchemy_pages,
                       on_delete: :cascade,
                       on_update: :cascade,
                     }
    if index_exists? :alchemy_elements,
                     :parent_element_id,
                     name: "index_alchemy_elements_on_page_id_and_parent_element_id"
      remove_index :alchemy_elements,
                   column: [:parent_element_id],
                   name: "index_alchemy_elements_on_page_id_and_parent_element_id"
    end
    if index_exists? :alchemy_elements,
                     :position,
                     name: "index_elements_on_page_id_and_position"
      remove_index :alchemy_elements,
                   column: [:position],
                   name: "index_elements_on_page_id_and_position"
    end
  end
end
