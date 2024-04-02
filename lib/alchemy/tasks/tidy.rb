# frozen_string_literal: true

require "alchemy/shell"

module Alchemy
  class Tidy
    extend Shell

    class << self
      def update_element_positions
        puts "\n## Updating element positions"

        count = 0
        Alchemy::Page.all.includes(draft_version: :elements, public_version: :elements).find_each do |page|
          fix_element_positions(page.draft_version, count)
          if page.public_version
            fix_element_positions(page.public_version, count)
          end
        end
        puts "\n#{count}"

        if count.positive?
          log "Fixed #{count} element positions"
        else
          log "All element positions are correct"
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

      def remove_trashed_elements
        puts "\n## Removing trashed elements"
        elements = Alchemy::Element.unscoped.where(position: nil)
        if elements.any?
          log "Destroying #{elements.size} trashed elements"
          nested_elements, parent_elements = elements.partition(&:parent_element_id)
          (nested_elements + parent_elements).each do |element|
            element.destroy
            print "."
          end
          puts "\n"
          log "Done", :message
        else
          log "No trashed elements found", :skip
        end
      end

      def remove_duplicate_legacy_urls
        puts "\n## Removing duplicate legacy URLs"
        sql = <<~SQL
          DELETE FROM alchemy_legacy_page_urls A USING alchemy_legacy_page_urls B
          WHERE A.page_id = B.page_id
            AND A.urlname = B.urlname
            AND A.id < B.id
        SQL
        count = ActiveRecord::Base.connection.exec_delete(sql)
        log "Deleted #{count} duplicate legacy URLs"
      end

      private

      def fix_element_positions(page_version, count)
        page_version.elements.fixed.group_by(&:parent_element_id).each do |_, elements|
          fix_positions(elements, count)
        end
        page_version.elements.unfixed.group_by(&:parent_element_id).each do |_, elements|
          fix_positions(elements, count)
        end
      end

      def fix_positions(elements, count)
        elements.each.with_index(1) do |element, position|
          if element.position != position
            element.update_column(:position, position)
            count += 1
            print "F"
          else
            print "."
          end
        end
      end

      def destroy_orphaned_records(records, class_name)
        records.each do |record|
          log "Destroy orphaned #{class_name}: #{record.inspect}"
          record.destroy
        end
      end
    end
  end
end
