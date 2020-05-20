# frozen_string_literal: true
require "alchemy/shell"

module Alchemy
  class Tidy
    extend Shell

    class << self
      def update_element_positions
        Alchemy::Page.all.each do |page|
          if page.elements.any?
            puts "\n## Updating element positions of page `#{page.name}`"
          end
          page.elements.group_by(&:parent_element_id).each do |_, elements|
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
          element.contents.group_by(&:element_id).each do |_, contents|
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

      def remove_orphaned_elements
        puts "\n## Removing orphaned elements"
        elements = Alchemy::Element.unscoped.not_nested
        if elements.any?
          orphaned_elements = elements.select do |element|
            element.page.nil? && element.page_id.present?
          end
          if orphaned_elements.any?
            log "Found #{orphaned_elements.size} orphaned elements"
            destroy_orphaned_records(orphaned_elements, "element")
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
            destroy_orphaned_records(orphaned_contents, "content")
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
