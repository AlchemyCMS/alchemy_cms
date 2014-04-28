require 'alchemy/seeder'
require 'alchemy/tasks/helpers'
include Alchemy::Tasks::Helpers

namespace :alchemy do
  namespace :db do

    desc "Seeds your database with essential data for Alchemy CMS."
    task :seed => :environment do
      Alchemy::Seeder.seed!
    end

    desc "Dumps the database to STDOUT (Pass DUMP_FILENAME to store the dump into a file)."
    task :dump => :environment do
      dump_store = ENV['DUMP_FILENAME'] ? " > #{ENV['DUMP_FILENAME']}" : ""
      dump_cmd = database_dump_command(database_config['adapter'])
      system "#{dump_cmd}#{dump_store}"
    end

  end
end
