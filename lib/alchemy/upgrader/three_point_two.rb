require_relative 'tasks/three_point_two_task'

module Alchemy
  class Upgrader::ThreePointTwo < Upgrader
    class << self
      def upgrade_acts_as_taggable_on_migrations
        desc 'Install and patch acts_as_taggable_on migrations.'
        if !`bundle exec rake railties:install:migrations FROM=acts_as_taggable_on_engine`.empty?
          Alchemy::Upgrader::Tasks::ThreePointTwoTask.new.patch_acts_as_taggable_on_migrations
        end
        `bundle exec rake db:migrate`
      end

      def inject_seeder
        desc 'Add Alchemy seeder to `db/seeds.rb` file.'
        Alchemy::Upgrader::Tasks::ThreePointTwoTask.new.inject_seeder
      end

      def alchemy_3_2_todos
        notice = <<-NOTE

  Capistrano 2 deploy script removed
  ----------------------------------

  The Capistrano 2 based deploy script has been removed and replaced by an Capistrano 3 extension.

  Please update your Gemfile:

  group :development do
    gem 'capistrano-alchemy', github: 'AlchemyCMS/capistrano-alchemy', branch: 'master', require: false
  end

  For more information please visit https://github.com/AlchemyCMS/capistrano-alchemy.

  NOTE
        todo notice, 'Alchemy v3.2 changes'
      end
    end
  end
end
