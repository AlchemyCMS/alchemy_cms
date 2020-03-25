# frozen_string_literal: true

require_relative 'tasks/harden_gutentag_migrations'

module Alchemy
  class Upgrader::FivePointZero < Upgrader
    class << self
      def install_gutentag_migrations
        desc 'Install Gutentag migrations'
        `bundle exec rake gutentag:install:migrations`
        Alchemy::Upgrader::Tasks::HardenGutentagMigrations.new.patch_migrations
        `bundle exec rake db:migrate`
      end
    end
  end
end
