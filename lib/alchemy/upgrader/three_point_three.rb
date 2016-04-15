require_relative 'tasks/available_contents_upgrader'
require_relative 'tasks/nestable_elements_migration'

module Alchemy
  module Upgrader::ThreePointThree
    private

    def convert_available_contents
      desc 'Convert `available_contents` config to `nestable_elements`.'
      Alchemy::Upgrader::Tasks::AvailableContentsUpgrader.new.convert_available_contents
    end

    def migrate_existing_elements
      desc 'Migrate existing elements to `nestable_elements`.'
      Alchemy::Upgrader::Tasks::NestableElementsMigration.new.migrate_existing_elements
    end

    def alchemy_3_3_todos
      notice = <<-NOTE

Element's "available_contents" feature removed
----------------------------------------------

The `available_contents` feature of elements was removed and has been replaced by nestable elements.

The automatic updater that just ran updated your `config/alchemy/elements.yml`. A backup was made.
Nevertheless, you should have a look into it and double check the changes.

We defined elements for each content type former defined in `available_contents` and put its name
into a new `nestable_elements` collection in the elements definition.

We also updated your element view partials so they render the child elements.
Please review and fix markup, if necessary.

The code for the available contents buttons and links in the element editor partials were removed
without replacement, because the nested elements editor partials render automatically.

PLEASE DOUBLE CHECK YOUR ELEMENT PARTIALS AND ADJUST ACCORDINGLY!

Uploader `allowed_filetypes` setting changed
--------------------------------------------

The name of the model is now namespaced. `alchemy/pictures` instead of just `pictures`.
Please ensure, to copy the new setting from the `config.yml.defaults` file.

NOTE
      todo notice, 'Alchemy v3.3 changes'
    end
  end
end
