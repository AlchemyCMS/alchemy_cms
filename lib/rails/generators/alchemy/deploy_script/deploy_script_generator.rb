require 'rails/generators'

module Alchemy
	module Generators
		class DeployScriptGenerator < ::Rails::Generators::Base

			desc "This generator generates a Capistrano deploy script."
			class_option :scm, :type => :string, :desc => "Set the type of scm you use for deployment.", :default => 'svn'
			class_option :db, :type => :string, :desc => "Set the type of database you use on your server.", :default => 'mysql'
			source_root File.expand_path('templates', File.dirname(__FILE__))

			def copy_script
				@ssh_user = ask('Please enter SSH username:')
				@ssh_password = ask('Please enter SSH password:')
				port = ask('Please enter SSH port (22):')
				@ssh_port = port.blank? ? 22 : port
				@server = ask('Please enter server ip or domain:')
				@deploy_path = ask('Please enter the path to the public html folder:')
				@scm = options[:scm]
				@repository_url = ask('Please enter the URL to your projects repository:')
				if @scm == "svn" && yes?('Is your repository private? (y/N)')
					@scm_user = ask('Please enter the username for your repository:')
					@scm_password = ask('Please enter the password to your repository:')
				end
				@database_type = options[:db]
				template "deploy.rb.tt", Rails.root.join('config', 'deploy.rb')
			end

		end
	end
end
