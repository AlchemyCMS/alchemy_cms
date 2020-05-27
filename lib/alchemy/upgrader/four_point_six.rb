# frozen_string_literal: true

module Alchemy
  class Upgrader::FourPointSix < Upgrader
    class << self
      def restructure_page_tree
        desc "Move child pages of invisible pages to visible parent."
        pages = Alchemy::Page.contentpages.where(visible: [false, nil]).order(depth: :desc)
        if pages.size > 0
          log "Moving #{pages.size} page(s). Please wait..."
          pages.find_each do |page|
            parent = visible_parent(page.parent)
            Alchemy::Page.transaction do
              if parent
                page.children.find_each { |child| child.move_to_child_of(parent) }
              end
              page.update!(visible: true)
            end
            print "."
          end
          puts "\n"
          log "Done!"
        else
          log "No invisible pages found!", :skip
        end
      end

      private

      def visible_parent(page)
        return unless page
        return page if page.visible? || page.language_root?

        visible_parent(page.parent)
      end
    end
  end
end
