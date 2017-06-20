require 'alchemy/shell'

namespace :alchemy do
  namespace :tidy do
    desc "Tidy up Alchemy database."
    task :up do
      Rake::Task['alchemy:tidy:cells'].invoke
      Rake::Task['alchemy:tidy:element_positions'].invoke
      Rake::Task['alchemy:tidy:content_positions'].invoke
      Rake::Task['alchemy:tidy:remove_orphaned_records'].invoke
    end

    desc "Creates missing cells for pages."
    task cells: :environment do
      if !File.exist? Rails.root.join('config/alchemy/cells.yml')
        puts "No page cell definitions found."
      else
        cells = Alchemy::Cell.definitions
        page_layouts = Alchemy::PageLayout.all
        if cells && page_layouts
          Alchemy::Tidy.create_missing_cells(page_layouts, cells)
        else
          puts "No page layouts or cell definitions found."
        end
      end
    end

    desc "Fixes element positions."
    task element_positions: [:environment] do
      Alchemy::Tidy.update_element_positions
    end

    desc "Fixes content positions."
    task content_positions: [:environment] do
      Alchemy::Tidy.update_content_positions
    end

    desc "Remove orphaned records (cells, elements, contents)."
    task remove_orphaned_records: [:environment] do
      Rake::Task['alchemy:tidy:remove_orphaned_cells'].invoke
      Rake::Task['alchemy:tidy:remove_orphaned_elements'].invoke
      Rake::Task['alchemy:tidy:remove_orphaned_contents'].invoke
    end

    desc "Remove orphaned cells."
    task remove_orphaned_cells: [:environment] do
      Alchemy::Tidy.remove_orphaned_cells
    end

    desc "Remove orphaned elements."
    task remove_orphaned_elements: [:environment] do
      Alchemy::Tidy.remove_orphaned_elements
    end

    desc "Remove orphaned contents."
    task remove_orphaned_contents: [:environment] do
      Alchemy::Tidy.remove_orphaned_contents
    end
  end
end

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
              cell.elements << page.elements.select { |element| cell_for_layout['elements'].include?(element.name) }
              if cell.new_record?
                cell.save
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
          log "Destroy orphaned #{class_name}: #{record.id}"
          record.destroy
        end
      end
    end
  end
end
