require 'alchemy/shell'

module Alchemy
  class Tidy
    extend Shell

    class << self
      def create_missing_cells(page_layouts, cells)
        page_layouts.each do |layout|
          next if layout['cells'].blank?
          cells_for_layout = cells.select { |cell| layout['cells'].include? cell['name'] }
          Alchemy::Page.where(page_layout: layout['name']).each do |page|
            cells_for_layout.each do |cell_for_layout|
              cell = Alchemy::Cell.find_or_initialize_by(name: cell_for_layout['name'], page_id: page.id)
              if cell.new_record?
                log "Creating cell #{cell.name} for page #{page.name}"
              else
                log "Cell #{cell.name} for page #{page.name} already present", :skip
              end
            end
          end
        end
      end

      def update_element_positions
        Alchemy::Page.all.each do |page|
          if page.elements.any?
            puts "\n## Updating element positions of page `#{page.name}`"
          end
          page.elements.group_by(&:cell_id).each do |_cell_id, elements|
            elements.each_with_index do |element, idx|
              position = idx + 1
              if element.position != position
                log "Updating position for element ##{element.id} to #{position}"
                element.update_column(:position, position)
              else
                log "Position for element ##{element.id} is already correct (#{position})", :skip
              end
            end
          end
        end
      end

      def update_content_positions
        Alchemy::Element.all.each do |element|
          if element.contents.any?
            puts "\n## Updating content positions of element `#{element.name}`"
          end
          element.contents.group_by(&:essence_type).each do |essence_type, contents|
            puts "-> Contents of type `#{essence_type}`"
            contents.each_with_index do |content, idx|
              position = idx + 1
              if content.position != position
                log "Updating position for content ##{content.id} to #{position}"
                content.update_column(:position, position)
              else
                log "Position for content ##{content.id} is already correct (#{position})", :skip
              end
            end
          end
        end
      end

      def remove_orphaned_cells
        puts "\n## Removing orphaned cells"
        cells = Alchemy::Cell.unscoped.all
        if cells.any?
          orphaned_cells = cells.select do |cell|
            cell.page.nil? && cell.page_id.present?
          end
          if orphaned_cells.any?
            log "Found #{orphaned_cells.size} orphaned cells"
            destroy_orphaned_records(orphaned_cells, 'cell')
          else
            log "No orphaned cells found", :skip
          end
        else
          log "No cells found", :skip
        end
      end

      def remove_orphaned_elements
        puts "\n## Removing orphaned elements"
        elements = Alchemy::Element.unscoped.all
        if elements.any?
          orphaned_elements = elements.select do |element|
            element.page.nil? && element.page_id.present? ||
              element.cell.nil? && element.cell_id.present?
          end
          if orphaned_elements.any?
            log "Found #{orphaned_elements.size} orphaned elements"
            destroy_orphaned_records(orphaned_elements, 'element')
          else
            log "No orphaned elements found", :skip
          end
        else
          log "No elements found", :skip
        end
      end

      def remove_orphaned_contents
        puts "\n## Removing orphaned contents"
        contents = Alchemy::Content.unscoped.all
        if contents.any?
          orphaned_contents = contents.select do |content|
            content.essence.nil? && content.essence_id.present? ||
              content.element.nil? && content.element_id.present?
          end
          if orphaned_contents.any?
            log "Found #{orphaned_contents.size} orphaned contents"
            destroy_orphaned_records(orphaned_contents, 'content')
          else
            log "No orphaned contents found", :skip
          end
        else
          log "No contents found", :skip
        end
      end

      private

      def destroy_orphaned_records(records, class_name)
        records.each do |record|
          log "Destroy orphaned #{class_name}: #{record.inspect}"
          record.destroy
        end
      end
    end
  end
end
