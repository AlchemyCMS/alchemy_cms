require 'alchemy/seeder'
require 'alchemy/tasks/helpers'
include Alchemy::Tasks::Helpers

namespace :alchemy do
  namespace :db do

    desc "Seeds your database with essential data for Alchemy CMS."
    task :seed => :environment do
      Alchemy::Seeder.seed!
    end

    desc "Dumps the database to STDOUT (Pass DUMP_FILENAME to store the dump into a file). NOTE: This only works with MySQL yet."
    task :dump => :environment do
      raise "Sorry, but Alchemy only supports MySQL database dumping at the moment." unless database_config['adapter'] =~ /mysql/
      dump_store = ENV['DUMP_FILENAME'] ? " > #{ENV['DUMP_FILENAME']}" : ""
      system "mysqldump #{mysql_credentials} #{database_config['database']}#{dump_store}"
    end

  end
end
