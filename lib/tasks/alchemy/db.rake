require 'shellwords'
require 'alchemy/seeder'
require 'alchemy/tasks/helpers'

namespace :alchemy do
  namespace :db do
    include Alchemy::Tasks::Helpers

    desc "Seeds the database with Alchemy defaults"
    task seed: [:environment] do
      Alchemy::Seeder.seed!
    end

    desc "Dumps the database to STDOUT (Pass DUMP_FILENAME to store the dump into a file)."
    task dump: :environment do
      dump_store = ENV['DUMP_FILENAME'] ? " > #{ENV['DUMP_FILENAME']}" : ""
      dump_cmd = database_dump_command(database_config['adapter'])
      system "#{dump_cmd}#{dump_store}"
    end

    desc "Imports the database from STDIN (Pass DUMP_FILENAME to read the dump from file)."
    task import: :environment do
      dump_store = ENV['DUMP_FILENAME'] ? "cat #{ENV['DUMP_FILENAME']}" : "echo #{Shellwords.escape(STDIN.read)}"
      import_cmd = database_import_command(database_config['adapter'])
      system "#{dump_store} | #{import_cmd}"
    end
  end
end
