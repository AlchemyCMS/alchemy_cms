require "alchemy/shell"
require "benchmark"
require "dragonfly"
require "fileutils"
require "thor"

module Alchemy
  class Upgrader::EightZero < Upgrader
    include Thor::Base
    include Thor::Actions

    class << self
      def install_active_storage
        Rake::Task["active_storage:install"].invoke
        Rake::Task["db:migrate"].invoke

        todo <<-TXT.strip_heredoc
          Using Dragonfly as file storage is deprecated
          and you need to migrate files to ActiveStorage.

          We provide tasks to help you with that.

          Please read the `docs/active_storage_migration.md` file
          for further instructions.

        TXT
      end

      private

      def task
        @_task || new
      end
    end
  end
end
