require 'alchemy/upgrader'
require 'alchemy/version'

namespace :alchemy do
  desc "Upgrades your app to Alchemy CMS v#{Alchemy::VERSION} (Set UPGRADE env variable to only run a specific task)."
  task upgrade: [
    'alchemy:install:migrations',
    'db:migrate',
    'alchemy:db:seed',
    'alchemy:upgrade:config',
    'alchemy:upgrade:run'
  ]

  namespace :upgrade do
    desc "Alchemy Upgrader: Run only the upgrader tasks without preparation"
    task run: [
      'alchemy:upgrade:3.0',
      'alchemy:upgrade:3.1',
      'alchemy:upgrade:3.2',
      'alchemy:upgrade:3.3'
    ] do
      Alchemy::Upgrader.run!
    end

    desc "Alchemy Upgrader: Copy configuration file."
    task config: [:environment] do |t|
      Alchemy::Upgrader.copy_new_config_file
    end

    desc "Alchemy Upgrader: List all upgrade tasks."
    task list: [:environment] do
      puts "\nAvailable upgrade tasks"
      puts "-----------------------\n"
      methods = Alchemy::Upgrader.all_upgrade_tasks
      if methods.any?
        methods.each { |method| puts method }
        puts "\nUsage:"
        puts "------"
        puts "Run one or more tasks with `bundle exec rake alchemy:upgrade UPGRADE=task_name1,task_name2`\n"
      else
        puts "No upgrades available."
      end
    end

    task fix_picture_format: [:environment] do
      Alchemy::Picture.find_each do |picture|
        picture.update_column(:image_file_format, picture.image_file_format.to_s.chomp)
      end
    end

    desc 'Upgrade Alchemy to v3.0'
    task '3.0': ['alchemy:upgrade:3.0:run']

    namespace '3.0' do
      task run: [
        'alchemy:upgrade:3.0:rename_registered_role_ro_member',
        'alchemy:upgrade:3.0:publish_unpublished_public_pages',
        'alchemy:upgrade:3.0:todo'
      ] do
        Alchemy::Upgrader.display_todos
      end

      desc 'Rename the `registered` user role to `member`'
      task rename_registered_role_ro_member: [:environment] do |t|
        Alchemy::Upgrader::ThreePointZero.rename_registered_role_ro_member
      end

      desc 'Sets `published_at` of public pages without a `published_at` date set to their `updated_at` value'
      task publish_unpublished_public_pages: [:environment] do |t|
        Alchemy::Upgrader::ThreePointZero.publish_unpublished_public_pages
      end

      task :todo do |t|
        Alchemy::Upgrader::ThreePointZero.alchemy_3_0_todos
      end
    end

    desc 'Display Alchemy v3.1 upgrade todos'
    task '3.1' do
      Alchemy::Upgrader::ThreePointOne.alchemy_3_1_todos
      Alchemy::Upgrader.display_todos
    end

    desc 'Upgrade Alchemy to v3.2'
    task '3.2': ['alchemy:upgrade:3.2:run']

    namespace '3.2' do
      task run: [
        'alchemy:upgrade:3.2:upgrade_acts_as_taggable_on_migrations',
        'alchemy:upgrade:3.2:inject_seeder',
        'alchemy:upgrade:3.2:todo'
      ] do
        Alchemy::Upgrader.display_todos
      end

      desc 'Install and patch acts_as_taggable_on migrations.'
      task upgrade_acts_as_taggable_on_migrations: [:environment] do |t|
        Alchemy::Upgrader::ThreePointTwo.upgrade_acts_as_taggable_on_migrations
      end

      desc 'Add Alchemy seeder to `db/seeds.rb` file.'
      task inject_seeder: [:environment] do |t|
        Alchemy::Upgrader::ThreePointTwo.inject_seeder
      end

      task :todo do |t|
        Alchemy::Upgrader::ThreePointTwo.alchemy_3_2_todos
      end
    end

    desc 'Upgrade Alchemy to v3.3'
    task '3.3': ['alchemy:upgrade:3.3:run']

    namespace '3.3' do
      task run: [
        'alchemy:upgrade:3.3:convert_available_contents',
        'alchemy:upgrade:3.3:migrate_existing_elements',
        'alchemy:upgrade:3.3:todo'
      ] do
        Alchemy::Upgrader.display_todos
      end

      desc 'Convert `available_contents` config to `nestable_elements`.'
      task convert_available_contents: [:environment] do |t|
        Alchemy::Upgrader::ThreePointThree.convert_available_contents
      end

      desc 'Migrate existing elements to `nestable_elements`.'
      task migrate_existing_elements: [:environment] do |t|
        Alchemy::Upgrader::ThreePointThree.migrate_existing_elements
      end

      task :todo do |t|
        Alchemy::Upgrader::ThreePointThree.alchemy_3_3_todos
      end
    end
  end
end
