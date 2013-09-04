require 'alchemy/upgrader'
require 'alchemy/version'

namespace :alchemy do

  desc "Upgrades database content to Alchemy CMS v#{Alchemy::VERSION} (Set UPGRADE env variable to only run a specific task)."
  task :upgrade => :environment do
    Alchemy::Upgrader.run!
  end

  namespace :upgrade do
    desc "List all available upgrade tasks."
    task :list => [:environment] do
      puts "\nAvailable upgrade tasks"
      puts "-----------------------\n"
      methods = Alchemy::Upgrader.all_upgrade_tasks
      if methods.any?
        methods.each { |method| puts method }
        puts "\nUsage:"
        puts "------"
        puts "Run one or more tasks with `bundle exec rake alchemy:upgrade UPGRADE=task_name1,task_name2`\n"
      else
        puts "No upgrades available."
      end
    end
  end

end
