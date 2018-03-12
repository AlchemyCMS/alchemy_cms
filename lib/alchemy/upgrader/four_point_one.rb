require_relative 'tasks/harden_acts_as_taggable_on_migrations'

module Alchemy
  class Upgrader::FourPointOne < Upgrader
    class << self
      def harden_acts_as_taggable_on_migrations
        desc 'Harden `acts_as_taggable_on_migrations`'
        `bundle exec rake railties:install:migrations FROM=acts_as_taggable_on_engine`
        Alchemy::Upgrader::Tasks::HardenActsAsTaggableOnMigrations.new.patch_migrations
        `bundle exec rake db:migrate`
      end

      def alchemy_4_1_todos
        notice = <<-NOTE

        Changed tagging provider to Gutentag
        ------------------------------------

        The automatic updater that just ran updated all existing `acts_as_taggable_on_migrations`,
        so that they don't blow up if the `acts_as_taggable_on` gem is no longer available.

        All your existing tags have been migrated to `Gutentag::Tag`s.

        NOTE
        todo notice, 'Alchemy v4.1 changes'
      end
    end
  end
end
