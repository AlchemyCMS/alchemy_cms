require 'alchemy/shell'

namespace :alchemy do
  namespace :tidy do

    desc "Tidy up Alchemy database."
    task :up do
      Rake::Task['alchemy:tidy:cells'].invoke
      Rake::Task['alchemy:tidy:element_positions'].invoke
      Rake::Task['alchemy:tidy:content_positions'].invoke
    end

    desc "Creates missing cells for pages."
    task :cells => :environment do
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
    task :element_positions => [:environment] do
      Alchemy::Tidy.update_element_positions
    end

    desc "Fixes content positions."
    task :content_positions => [:environment] do
      Alchemy::Tidy.update_content_positions
    end
  end
end

module Alchemy
  class Tidy
    extend Shell

    def self.create_missing_cells(page_layouts, cells)
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

    def self.update_element_positions
      Alchemy::Page.all.each do |page|
        if page.elements.any?
          puts "\n## Updating element positions of page `#{page.name}`"
        end
        page.elements.group_by(&:cell_id).each do |cell_id, elements|
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

    def self.update_content_positions
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
  end
end
