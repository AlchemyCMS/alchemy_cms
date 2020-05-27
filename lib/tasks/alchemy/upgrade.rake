# frozen_string_literal: true

require "alchemy/upgrader"
require "alchemy/version"

namespace :alchemy do
  desc "Upgrades your app to AlchemyCMS v#{Alchemy::VERSION}."
  task upgrade: [
    "alchemy:upgrade:prepare",
    "alchemy:upgrade:4.1:run", "alchemy:upgrade:4.1:todo",
    "alchemy:upgrade:4.2:run", "alchemy:upgrade:4.2:todo",
    "alchemy:upgrade:4.4:run", "alchemy:upgrade:4.4:todo",
    "alchemy:upgrade:4.6:run", "alchemy:upgrade:4.6:todo",
  ] do
    Alchemy::Upgrader.display_todos
  end

  namespace :upgrade do
    desc "Alchemy Upgrader: Prepares the database and updates Alchemys configuration file."
    task prepare: [
      "alchemy:upgrade:database",
      "alchemy:upgrade:config",
    ]

    desc "Alchemy Upgrader: Prepares the database."
    task database: [
      "alchemy:install:migrations",
      "db:migrate",
      "alchemy:db:seed",
    ]

    desc "Alchemy Upgrader: Copy configuration file."
    task config: [:environment] do
      Alchemy::Upgrader.copy_new_config_file
    end

    task fix_picture_format: [:environment] do
      Alchemy::Picture.find_each do |picture|
        picture.update_column(:image_file_format, picture.image_file_format.to_s.chomp)
      end
    end

    desc "Upgrade Alchemy to v4.1"
    task "4.1" => [
      "alchemy:upgrade:prepare",
      "alchemy:upgrade:4.1:run",
      "alchemy:upgrade:4.1:todo",
    ] do
      Alchemy::Upgrader.display_todos
    end

    namespace "4.1" do
      task run: ["alchemy:upgrade:4.1:harden_acts_as_taggable_on_migrations"]

      desc "Harden acts_as_taggable_on migrations"
      task harden_acts_as_taggable_on_migrations: [:environment] do
        Alchemy::Upgrader::FourPointOne.harden_acts_as_taggable_on_migrations
      end

      task :todo do
        Alchemy::Upgrader::FourPointOne.alchemy_4_1_todos
      end
    end

    desc "Upgrade Alchemy to v4.2"
    task "4.2" => [
      "alchemy:upgrade:prepare",
      "alchemy:upgrade:4.2:run",
      "alchemy:upgrade:4.2:todo",
    ] do
      Alchemy::Upgrader.display_todos
    end

    namespace "4.2" do
      task run: [
        "alchemy:upgrade:4.2:convert_picture_galleries",
        "alchemy:upgrade:4.2:migrate_picture_galleries",
        "alchemy:upgrade:4.2:convert_cells",
        "alchemy:upgrade:4.2:migrate_cells",
        "alchemy:upgrade:4.2:update_element_partial_name_variable",
      ]

      desc "Convert `picture_gallery` element definitions to `nestable_elements`."
      task convert_picture_galleries: [:environment] do
        Alchemy::Upgrader::FourPointTwo.convert_picture_galleries
      end

      desc "Migrate `picture_gallery` elements to `nestable_elements`."
      task migrate_picture_galleries: [:environment] do
        Alchemy::Upgrader::FourPointTwo.migrate_picture_galleries
      end

      desc "Convert cells config to fixed nestable elements."
      task convert_cells: [:environment] do
        Alchemy::Upgrader::FourPointTwo.convert_cells
      end

      desc "Migrate existing cells to fixed nestable elements."
      task migrate_cells: ["alchemy:install:migrations", "db:migrate"] do
        Alchemy::Upgrader::FourPointTwo.migrate_cells
      end

      desc "Update element views to use element partial name variable."
      task :update_element_partial_name_variable do
        Alchemy::Upgrader::FourPointTwo.update_element_views_variable_name
      end

      task :todo do
        Alchemy::Upgrader::FourPointTwo.alchemy_4_2_todos
      end
    end

    desc "Upgrade Alchemy to v4.4"
    task "4.4" => [
      "alchemy:upgrade:prepare",
      "alchemy:upgrade:4.4:run",
      "alchemy:upgrade:4.4:todo",
    ] do
      Alchemy::Upgrader.display_todos
    end

    namespace "4.4" do
      task run: [
        "alchemy:upgrade:4.4:rename_element_views",
        "alchemy:upgrade:4.4:update_local_variable",
      ]

      desc "Remove '_view' suffix from element views."
      task rename_element_views: [:environment] do
        Alchemy::Upgrader::FourPointFour.rename_element_views
      end

      desc "Update element views local variable to element name."
      task update_local_variable: [:environment] do
        Alchemy::Upgrader::FourPointFour.update_local_variable
      end

      task :todo do
        Alchemy::Upgrader::FourPointFour.alchemy_4_4_todos
      end
    end

    desc "Upgrade Alchemy to v4.6"
    task "4.6" => [
      "alchemy:upgrade:prepare",
    ]

    namespace "4.6" do
      task run: []

      desc "Move child pages of invisible pages to visible parent."
      task restructure_page_tree: [:environment] do
        Alchemy::Upgrader::FourPointSix.restructure_page_tree
      end

      task :todo do
        Alchemy::Upgrader::FourPointSix.todos
      end
    end
  end
end
