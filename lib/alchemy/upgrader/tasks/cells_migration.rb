module Alchemy::Upgrader::Tasks
  class CellsMigration
    class Cell < ActiveRecord::Base
      self.table_name = 'alchemy_cells'
      belongs_to :page, class_name: 'Alchemy::Page'
    end

    def migrate_cells
      if ActiveRecord::Base.connection.data_source_exists?('alchemy_cells')
        cells = Cell.all
        @fixed_element_name_finder = FixedElementNameFinder.new

        if cells.any?
          cells.each do |cell|
            migrate_cell!(cell)
          end
        else
          puts "No cells found. Skip"
        end
      else
        puts "Cells table does not exist. Skip"
      end
    end

    private

    def migrate_cell!(cell)
      # bust element definitions insta cache
      Alchemy::Element.instance_variable_set('@definitions', nil)
      fixed_element = Alchemy::Element.find_or_initialize_by(fixed: true, name: @fixed_element_name_finder.call(cell.name), page: cell.page)
      elements = Alchemy::Element.where(cell_id: cell.id).order(position: :asc)

      if fixed_element.new_record?
        fixed_element.save!
        Alchemy::Element.acts_as_list_no_update do
          elements.update_all(parent_element_id: fixed_element.id)
        end
        puts "Created new fixed element '#{fixed_element.name}' for cell '#{cell.name}'."
      else
        puts "Element for cell '#{cell.name}' already present. Skip"
      end
    end
  end
end
