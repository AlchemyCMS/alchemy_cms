require 'alchemy/seeder'

namespace :alchemy do
  namespace :db do

    desc "Seeds your database with essential data for Alchemy CMS."
    task :seed => :environment do
      Alchemy::Seeder.seed!
    end

    desc "Dumps the database to STDOUT (Pass DUMP_FILENAME to store the dump into a file). NOTE: This only works with MySQL yet."
    task :dump => :environment do
      db_conf = Rails.configuration.database_configuration.fetch(Rails.env)
      raise "Sorry, but Alchemy only supports MySQL database dumping at the moment." unless db_conf['adapter'] =~ /mysql/
      dump_store = ENV['DUMP_FILENAME'] ? " > #{ENV['DUMP_FILENAME']}" : ""
      cmd = "mysqldump --user='#{db_conf['username']}'#{db_conf['password'].present? ? " --password='#{db_conf['password']}'" : nil} --host=#{db_conf['host'] || 'localhost'} #{db_conf['database']}#{dump_store}"
      system cmd
    end

  end
end
