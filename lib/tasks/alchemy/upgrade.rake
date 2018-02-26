require 'alchemy/upgrader'
require 'alchemy/version'

namespace :alchemy do
  desc "Upgrades your app to AlchemyCMS v#{Alchemy::VERSION}."
  task upgrade: [
    'alchemy:upgrade:prepare',
    'alchemy:upgrade:4.1:run', 'alchemy:upgrade:4.1:todo'
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
  end
end
