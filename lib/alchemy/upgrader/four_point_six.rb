# frozen_string_literal: true

module Alchemy
  class Upgrader::FourPointSix < Upgrader
    class << self
      def todos
        notice = <<-NOTE.strip_heredoc

          ℹ️  Page visible attribute is deprecated
          ----------------------------------------

          Page slugs will be visible in URLs of child pages all the time in the future.
          Please use Menus and Tags instead to re-organize your pages if your page tree does not reflect the URL hierarchy.

          A rake task to help with the migration is available.

              bin/rake alchemy:upgrade:4.6:restructure_page_tree

        NOTE
        todo notice, "Alchemy v4.6 TODO"
      end

      def restructure_page_tree
        desc "Move child pages of invisible pages to visible parent."
        Alchemy::Deprecation.silence do
          # All leaves can safely be marked visible
          Alchemy::Page.leaves.update_all(visible: true)
          Alchemy::Page.language_roots.each do |root_page|
            # Root pages are always visible
            root_page.update!(visible: true)
            remove_invisible_children(root_page)
          end
          Alchemy::Page.update_all(visible: true)
        end
      end

      private

      def remove_invisible_children(page)
        page.children.each { |child| remove_invisible_children(child) }
        if !page.visible
          page.children.reload.reverse.each do |child|
            puts "Moving #{child.urlname} to right of #{page.urlname}"
            child.move_to_right_of(page)
          end
        end
      end
    end
  end
end
