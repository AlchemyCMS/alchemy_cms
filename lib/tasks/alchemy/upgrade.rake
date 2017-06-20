require 'alchemy/upgrader'
require 'alchemy/version'

namespace :alchemy do
  desc "Upgrades your app to AlchemyCMS v#{Alchemy::VERSION}."
  task upgrade: [
    'alchemy:upgrade:prepare',
    'alchemy:upgrade:3.0:run', 'alchemy:upgrade:3.0:todo',
    'alchemy:upgrade:3.1:todo',
    'alchemy:upgrade:3.2:run', 'alchemy:upgrade:3.2:todo',
    'alchemy:upgrade:3.3:run', 'alchemy:upgrade:3.3:todo',
    'alchemy:upgrade:3.4:run',
    'alchemy:upgrade:3.5:run', 'alchemy:upgrade:3.5:todo'
  ] do
    Alchemy::Upgrader.display_todos
  end

  namespace :upgrade do
    desc 'Alchemy Upgrader: Prepares the database and updates Alchemys configuration file.'
    task prepare: [
      'alchemy:upgrade:database',
      'alchemy:upgrade:config'
    ]

    desc "Alchemy Upgrader: Prepares the database."
    task :database => [
      'alchemy:install:migrations',
      'db:migrate',
      'alchemy:db:seed'
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

    desc 'Upgrade Alchemy to v3.0'
    task '3.0' => [
      'alchemy:upgrade:prepare',
      'alchemy:upgrade:3.0:run',
      'alchemy:upgrade:3.0:todo'
    ] do
      Alchemy::Upgrader.display_todos
    end

    namespace '3.0' do
      task run: [
        'alchemy:upgrade:3.0:rename_registered_role_ro_member',
        'alchemy:upgrade:3.0:publish_unpublished_public_pages'
      ]

      desc 'Rename the `registered` user role to `member`'
      task rename_registered_role_ro_member: [:environment] do
        Alchemy::Upgrader::ThreePointZero.rename_registered_role_ro_member
      end

      desc 'Sets `published_at` of public pages without a `published_at` date set to their `updated_at` value'
      task publish_unpublished_public_pages: [:environment] do
        Alchemy::Upgrader::ThreePointZero.publish_unpublished_public_pages
      end

      task :todo do
        Alchemy::Upgrader::ThreePointZero.alchemy_3_0_todos
      end
    end

    desc 'Upgrade Alchemy to v3.1'
    task '3.1' => [
      'alchemy:upgrade:prepare',
      'alchemy:upgrade:3.1:todo'
    ] do
      Alchemy::Upgrader.display_todos
    end

    namespace '3.1' do
      task :todo do
        Alchemy::Upgrader::ThreePointOne.alchemy_3_1_todos
      end
    end

    desc 'Upgrade Alchemy to v3.2'
    task '3.2' => [
      'alchemy:upgrade:prepare',
      'alchemy:upgrade:3.2:run',
      'alchemy:upgrade:3.2:todo'
    ] do
      Alchemy::Upgrader.display_todos
    end

    namespace '3.2' do
      task run: [
        'alchemy:upgrade:3.2:upgrade_acts_as_taggable_on_migrations',
        'alchemy:upgrade:3.2:inject_seeder'
      ]

      desc 'Install and patch acts_as_taggable_on migrations.'
      task upgrade_acts_as_taggable_on_migrations: [:environment] do
        Alchemy::Upgrader::ThreePointTwo.upgrade_acts_as_taggable_on_migrations
      end

      desc 'Add Alchemy seeder to `db/seeds.rb` file.'
      task inject_seeder: [:environment] do
        Alchemy::Upgrader::ThreePointTwo.inject_seeder
      end

      task :todo do
        Alchemy::Upgrader::ThreePointTwo.alchemy_3_2_todos
      end
    end

    desc 'Upgrade Alchemy to v3.3'
    task '3.3' => [
      'alchemy:upgrade:prepare',
      'alchemy:upgrade:3.3:run',
      'alchemy:upgrade:3.3:todo'
    ] do
      Alchemy::Upgrader.display_todos
    end

    namespace '3.3' do
      task run: [
        'alchemy:upgrade:3.3:convert_available_contents',
        'alchemy:upgrade:3.3:migrate_existing_elements'
      ]

      desc 'Convert `available_contents` config to `nestable_elements`.'
      task convert_available_contents: [:environment] do
        Alchemy::Upgrader::ThreePointThree.convert_available_contents
      end

      desc 'Migrate existing elements to `nestable_elements`.'
      task migrate_existing_elements: [:environment] do
        Alchemy::Upgrader::ThreePointThree.migrate_existing_elements
      end

      task :todo do
        Alchemy::Upgrader::ThreePointThree.alchemy_3_3_todos
      end
    end

    desc 'Upgrade Alchemy to v3.4'
    task '3.4' => ['alchemy:upgrade:prepare', 'alchemy:upgrade:3.4:run']

    namespace '3.4' do
      task run: ['alchemy:upgrade:3.4:install_asset_manifests']

      desc 'Install asset manifests into `vendor/assets`'
      task install_asset_manifests: [:environment] do
        Alchemy::Upgrader::ThreePointFour.install_asset_manifests
      end
    end

    desc 'Upgrade Alchemy to v3.5'
    task '3.5' => [
      'alchemy:upgrade:prepare',
      'alchemy:upgrade:3.5:run',
      'alchemy:upgrade:3.5:todo'
    ] do
      Alchemy::Upgrader.display_todos
    end

    namespace '3.5' do
      task run: ['alchemy:upgrade:3.5:install_dragonfly_config']

      desc 'Install dragonfly config into `config/initializers`'
      task install_dragonfly_config: [:environment] do
        Alchemy::Upgrader::ThreePointFive.install_dragonfly_config
      end

      task :todo do
        Alchemy::Upgrader::ThreePointFive.alchemy_3_5_todos
      end
    end
  end
end
