require 'alchemy/upgrader'
require 'alchemy/version'

namespace :alchemy do
  desc "Upgrades your app to AlchemyCMS v#{Alchemy::VERSION}."
  task upgrade: [
    'alchemy:upgrade:prepare',
    'alchemy:upgrade:4.1:run', 'alchemy:upgrade:4.1:todo',
    'alchemy:upgrade:4.2:run', 'alchemy:upgrade:4.2:todo'
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
    task database: [
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

    desc 'Upgrade Alchemy to v4.1'
    task '4.1' => [
      'alchemy:upgrade:prepare',
      'alchemy:upgrade:4.1:run',
      'alchemy:upgrade:4.1:todo'
    ] do
      Alchemy::Upgrader.display_todos
    end

    namespace '4.1' do
      task run: ['alchemy:upgrade:4.1:harden_acts_as_taggable_on_migrations']

      desc 'Harden acts_as_taggable_on migrations'
      task harden_acts_as_taggable_on_migrations: [:environment] do
        Alchemy::Upgrader::FourPointOne.harden_acts_as_taggable_on_migrations
      end

      task :todo do
        Alchemy::Upgrader::FourPointOne.alchemy_4_1_todos
      end
    end

    desc 'Upgrade Alchemy to v4.2'
    task '4.2' => [
      'alchemy:upgrade:prepare',
      'alchemy:upgrade:4.2:run',
      'alchemy:upgrade:4.2:todo'
    ] do
      Alchemy::Upgrader.display_todos
    end

    namespace '4.2' do
      task run: [
        'alchemy:upgrade:4.2:convert_picture_galleries',
        'alchemy:upgrade:4.2:migrate_picture_galleries'
      ]

      desc 'Convert `picture_gallery` element definitions to `nestable_elements`.'
      task convert_picture_galleries: [:environment] do
        Alchemy::Upgrader::FourPointTwo.convert_picture_galleries
      end

      desc 'Migrate `picture_gallery` elements to `nestable_elements`.'
      task migrate_picture_galleries: [:environment] do
        Alchemy::Upgrader::FourPointTwo.migrate_picture_galleries
      end

      task :todo do
        Alchemy::Upgrader::FourPointTwo.alchemy_4_2_todos
      end
    end
  end
end
