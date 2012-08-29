require 'rails/generators'

module Alchemy
  module Generators
    class DeployScriptGenerator < ::Rails::Generators::Base

      desc "This generator generates a Capistrano receipt for deploying Alchemy CMS."
      class_option :scm, :type => :string, :desc => "Set the type of scm you use for deployment.", :default => 'git'
      class_option :db, :type => :string, :desc => "Set the type of database you use on your server.", :default => 'mysql'
      source_root File.expand_path('templates', File.dirname(__FILE__))

      def copy_script
        @server = ask('Please enter server ip or domain:')
        if !yes?('Do you use ssh public keys to connect to your server? (y/N)')
          if @store_credentials = yes?('Do want to store the ssh credentials? (PLEASE DO NOT STORE THEM IF THE REPOSITORY IS PUBLIC) (y/N)')
            @ssh_user = ask('Please enter ssh username:')
            @ssh_password = ask('Please enter ssh password:')
            port = ask('Please enter ssh port (22):')
            @ssh_port = port.blank? ? "22" : port
          end
        end
        @deploy_path = ask('Please enter the path to the public html folder:')
        @scm = options[:scm]
        @repository_url = ask('Please enter the URL to your projects repository:')
        if @scm == "svn" && yes?('Is your repository private? (y/N)')
          @scm_user = ask('Please enter the username for your repository:')
          @scm_password = ask('Please enter the password to your repository:')
        end
        @database_type = options[:db]
        template "deploy.rb.tt", Rails.root.join('config', 'deploy.rb')
        puts "\nSetting up Capistrano"
        `capify .`
        puts "\nWe are done!\n"
        puts "\nPlease run 'cap deploy:setup'\n to setup the server for deployment."
        puts "\nIf you want to deploy Alchemy the first time type:\ncap deploy:cold"
        puts "\nAfter the first deploy you just need to type:\ncap deploy"
      end

    end
  end
end
