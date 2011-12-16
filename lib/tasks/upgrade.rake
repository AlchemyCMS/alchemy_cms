require File.join(File.dirname(__FILE__), '../alchemy/upgrader.rb')

namespace :alchemy do

	desc "Upgrades database to Alchemy CMS v#{Alchemy::VERSION}."
	task :upgrade => :environment do
		Rake::Task['alchemy:db:seed'].invoke
		Alchemy::Upgrader.run!
	end

end
