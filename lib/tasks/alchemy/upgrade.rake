require File.join(File.dirname(__FILE__), '../../alchemy/upgrader.rb')

namespace :alchemy do

  desc "Upgrades database content to Alchemy CMS v#{Alchemy::VERSION} (Set UPGRADE env variable to only run a specific task)."
  task :upgrade => :environment do
    Alchemy::Upgrader.run!
  end

  namespace :upgrade do
    desc "List all available upgrade tasks."
    task :list => [:environment] do
      Alchemy::Upgrader.list_tasks
    end
  end

end
