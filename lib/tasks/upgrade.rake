require File.join(File.dirname(__FILE__), '../alchemy/upgrader.rb')

namespace :alchemy do

  desc "Upgrades database to Alchemy CMS v#{Alchemy::VERSION}."
  task :upgrade => :environment do
    Alchemy::Upgrader.run!
    Rake::Task['alchemy:upgrade:copy_config'].invoke
  end

  namespace :upgrade do

    desc "Copy configuration file."
    task :copy_config do
      config_file = 'config/alchemy/config.yml'
      default_config = File.join(File.dirname(__FILE__), '../../config/alchemy/config.yml')
      if FileUtils.identical? default_config, config_file
        puts "Configuration file already present."
      else
        puts "Custom configuration file found."
        FileUtils.cp default_config, 'config/alchemy/config.yml.defaults'
        puts "Copied new default configuration file."
        puts "Check the default configuration file (./config/alchemy/config.yml.defaults) for new configuration options and insert them into your config file."
      end
    end

  end

end
