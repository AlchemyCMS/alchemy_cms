require File.join(File.dirname(__FILE__), '../alchemy/upgrader.rb')

namespace :alchemy do

	desc "Upgrades database to Alchemy CMS v#{Alchemy::VERSION}."
	task :upgrade => :environment do
		Alchemy::Upgrader.run!
    Rake::Task['alchemy:upgrade:move_files'].invoke
    Rake::Task['alchemy:upgrade:convert_files'].invoke
    Rake::Task['alchemy:upgrade:copy_config'].invoke
	end

	namespace :upgrade do

		desc "Moves files and folders into Alchemy namespace."
		task :move_files do
			if File.exists?('app/views/elements')
				puts "Moving element views into Alchemy namespace"
				FileUtils.mkdir_p('app/views/alchemy/')
				FileUtils.mv('app/views/elements', 'app/views/alchemy/')
			end
			if File.exists?('app/views/page_layouts')
				puts "Moving page_layout views into Alchemy namespace"
				FileUtils.mkdir_p('app/views/alchemy/')
				FileUtils.mv('app/views/page_layouts', 'app/views/alchemy/')
			end
			if File.exists?('app/views/messages')
				puts "Moving messages views into Alchemy namespace"
				FileUtils.mkdir_p('app/views/alchemy/')
				FileUtils.mv('app/views/messages', 'app/views/alchemy/')
			end
			if File.exists?('app/views/navigation')
				puts "Moving navigation views into Alchemy namespace"
				FileUtils.mkdir_p('app/views/alchemy/')
				FileUtils.mv('app/views/navigation', 'app/views/alchemy/')
			end
			if File.exists?('app/views/layouts/pages.html.erb')
				puts "Rename pages layout into application layout"
				FileUtils.mv('app/views/layouts/pages.html.erb', 'app/views/layouts/application.html.erb')
			end
		end

		desc "Convert Models in files into Alchemy namespace"
		task :convert_files do
			files = Dir.glob("app/views/**/*.erb")
			files.each do |file_name|
				text = File.read(file_name)
				text.gsub!(/(\s|'|")Page/, '\1Alchemy::Page')
				text.gsub!(/(\s|'|")Element/, '\1Alchemy::Element')
				text.gsub!(/(\s|'|")Message/, '\1Alchemy::Message')
				text.gsub!(/(\s|'|")Content/, '\1Alchemy::Content')
				text.gsub!(/(\s|'|")EssencePicture/, '\1Alchemy::EssencePicture')
				text.gsub!(/(\s|'|")EssenceText/, '\1Alchemy::EssenceText')
				text.gsub!(/(\s|'|")EssenceRichtext/, '\1Alchemy::EssenceRichtext')
				File.open(file_name, "w") { |file| file.puts text }
			end
		end

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
