require_relative 'tasks/picture_gallery_upgrader'
require_relative 'tasks/picture_gallery_migration'
require_relative 'tasks/cells_upgrader'
require_relative 'tasks/cells_migration'

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

      def alchemy_4_2_todos
        notice = <<-NOTE

        Element's "picture_gallery" feature removed
        ----------------------------------------------

        The `picture_gallery` feature of elements was removed and has been replaced by nestable elements.

        The automatic updater that just ran updated your `config/alchemy/elements.yml`. A backup was made.
        Nevertheless, you should have a look into it and double check the changes.

        We created nested elements for each gallery picture we found in your database.

        We also updated your element view partials so they have hints about how to render the child elements.

        Cells replaced by fixed nestable elements
        -----------------------------------------

        The Cells feature has been replaced by fixed nestable elements.

        The automatic updater that just ran updated your `config/alchemy/elements.yml`.
        Nevertheless, you should have a look into it and double check the changes.

        We defined new fixed elements for each cell former defined in `cells.yml`
        and put its `elements` into the `nestable_elements` collection of the new elements definition.

        We also updated your element view partials so they render the child elements.

        Please review and fix markup, if necessary.

        PLEASE DOUBLE CHECK YOUR ELEMENT PARTIALS AND ADJUST ACCORDINGLY!

        As always `git diff` is your friend.

        NOTE
        todo notice, 'Alchemy v4.2 changes'
      end
    end
  end
end
