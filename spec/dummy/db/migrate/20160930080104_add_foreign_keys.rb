class AddForeignKeys < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        Alchemy::Cell.unscoped.all.select { |c| c.page.nil? && c.page_id.present? }.each(&:destroy)
        Alchemy::Content.unscoped.all.select { |c| c.essence.nil? && c.essence_id.present? }.each(&:destroy)
        Alchemy::Content.unscoped.all.select { |c| c.element.nil? && c.element_id.present? }.each(&:destroy)
        Alchemy::Element.unscoped.all.select { |e| e.page.nil? && e.page_id.present? }.each(&:destroy)
        Alchemy::Element.unscoped.all.select { |e| e.cell.nil? && e.cell_id.present? }.each(&:destroy)
      end
    end

    add_foreign_key :alchemy_cells, :alchemy_pages, column: :page_id, on_update: :cascade, on_delete: :cascade, name: :alchemy_cells_page_id_fkey
    add_foreign_key :alchemy_contents, :alchemy_elements, column: :element_id, on_update: :cascade, on_delete: :cascade, name: :alchemy_contents_element_id_fkey
    add_foreign_key :alchemy_elements, :alchemy_pages, column: :page_id, on_update: :cascade, on_delete: :cascade, name: :alchemy_elements_page_id_fkey
    add_foreign_key :alchemy_elements, :alchemy_cells, column: :cell_id, on_update: :cascade, on_delete: :cascade, name: :alchemy_elements_cell_id_fkey
  end
end
