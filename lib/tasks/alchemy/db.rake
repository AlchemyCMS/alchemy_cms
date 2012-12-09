namespace :alchemy do
  namespace :db do

    desc "Seeds your database with essential data for Alchemy CMS."
    task :seed => :environment do
      Alchemy::Seeder.seed!
    end

    desc "Dumps the database into 'db/dumps'. NOTE: This only works with MySQL yet."
    task :dump => :environment do
      db_conf = Rails.configuration.database_configuration.fetch(Rails.env)
      raise "Alchemy only supports MySQL database dumping at the moment." unless db_conf['adapter'] =~ /mysql/
      FileUtils.mkdir_p(Rails.root.join('db/dumps'))
      `mysqldump -u#{db_conf['username']}#{db_conf['password'].present? ? " -p'#{db_conf['password']}'" : nil} #{db_conf['database']} > #{Rails.root.join('db/dumps', dump_name)}`
    end

    def dump_name
      return ENV['DUMP_FILENAME'] if ENV['DUMP_FILENAME'].present?
      app_name = Rails.application.class.name.underscore.split('/').first
      timestamp = Time.now.strftime('%Y-%m-%d-%H-%M')
      dump_name = "#{app_name}-#{timestamp}.sql"
    end

  end
end
