require_relative 'tasks/picture_gallery_upgrader'
require_relative 'tasks/picture_gallery_migration'
require_relative 'tasks/cells_upgrader'
require_relative 'tasks/cells_migration'
require_relative 'tasks/element_partial_name_variable_updater'

module Alchemy
  class Upgrader::FourPointTwo < Upgrader
    class << self
      def convert_picture_galleries
        desc 'Convert `picture_gallery` element definitions to `nestable_elements`.'
        Alchemy::Upgrader::Tasks::PictureGalleryUpgrader.new.convert_picture_galleries
      end

      def migrate_picture_galleries
        desc 'Migrate existing gallery elements to `nestable_elements`.'
        Alchemy::Upgrader::Tasks::PictureGalleryMigration.new.migrate_picture_galleries
      end

      def convert_cells
        desc 'Convert cells config to fixed nestable elements.'
        Alchemy::Upgrader::Tasks::CellsUpgrader.new.convert_cells
      end

      def migrate_cells
        desc 'Migrate existing cells to fixed nestable elements.'
        Alchemy::Upgrader::Tasks::CellsMigration.new.migrate_cells
      end

      def update_element_views_variable_name
        desc 'Update element views to use element partial name variable.'
        Alchemy::Upgrader::Tasks::ElementPartialNameVariableUpdater.new.update_element_views
      end

      def alchemy_4_2_todos
        notice = <<-NOTE.strip_heredoc
          ⚠️  Element's "picture_gallery" feature removed
          ----------------------------------------------

          The `picture_gallery` feature of elements was removed and has been replaced by nestable elements.

          The automatic updater that just ran updated your `config/alchemy/elements.yml`. A backup was made.
          Nevertheless, you should have a look into it and double check the changes.

          We created nested elements for each gallery picture we found in your database.

          We also updated your element view partials so they have hints about how to render the child elements.

          🚨 PLEASE LOOK INTO YOUR ELEMENT VIEW PARTIALS AND FOLLOW THE INSTRUCTIONS!


          ⚠️️  Cells replaced by fixed nestable elements
          --------------------------------------------

          The Cells feature has been replaced by fixed nestable elements.

          The automatic updater that just ran updated your `config/alchemy/elements.yml`.
          Nevertheless, you should have a look into it and double check the changes.

          We defined new fixed elements for each cell former defined in `cells.yml`
          and put its `elements` into the `nestable_elements` collection of the new elements definition.

          We also updated your element view partials so they render the child elements.

          Please review and fix markup, if necessary.

          🚨 PLEASE DOUBLE CHECK YOUR ELEMENT PARTIALS AND ADJUST ACCORDINGLY!

          As always `git diff` is your friend.


          ℹ️  Element views use element partial name as local variable
          -----------------------------------------------------------

          The local `element` variable in your element views has been replaced by a variable named after the partial.
          A "article" element has a "_article_view.html.erb" partial and therefore a `article_view` local variable now.

          The former `element` variable is still present, though.

        NOTE
        todo notice, 'Alchemy v4.2 TODO'
      end
    end
  end
end
