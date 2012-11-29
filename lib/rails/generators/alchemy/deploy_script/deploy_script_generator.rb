require 'rails/generators'

module Alchemy
  module Generators
    class DeployScriptGenerator < ::Rails::Generators::Base

      desc "This generator generates a Capistrano receipt for deploying Alchemy CMS."
      class_option :scm, :type => :string, :desc => "Set the type of scm you use for deployment.", :default => 'git'
      class_option :db, :type => :string, :desc => "Set the type of database you use on your server.", :default => 'mysql'
      source_root File.expand_path('templates', File.dirname(__FILE__))

      def copy_script
        @scm = options[:scm]
        @database_type = options[:db]
        @app_name = ask('Please enter a name for your application:')
        @server = ask('Please enter server ip or domain:')
        if @store_credentials = yes?('Do want to store the ssh credentials? (PLEASE DO NOT STORE THEM IF THE REPOSITORY IS PUBLIC) (y/N)')
          ask_for_credentials
        end
        @deploy_path = ask('Please enter the path to the public html folder:')
        if @scm == "git"
          @repository_url = get_git_remote
        end
        if @repository_url.nil?
          @repository_url = ask('Please enter the URL to your projects repository:')
        end
        if @scm == "svn" && yes?('Is your repository private? (y/N)')
          ask_for_repo_credentials
        end
        template "deploy.rb.tt", Rails.root.join('config', 'deploy.rb')
        setup_capistrano
        show_read_me
      end

    private

      def ask_for_credentials
        @ssh_user = ask('Please enter ssh username:')
        port = ask('Please enter ssh port (22):')
        @ssh_port = port.blank? ? "22" : port
        @no_ssh_public_keys = !yes?('Do you use ssh public keys to connect to your server? (y/N)')
        if @no_ssh_public_keys
          @ssh_password = ask('Please enter ssh password:')
        end
      end

      def ask_for_repo_credentials
        @scm_user = ask('Please enter the username for your repository:')
        @scm_password = ask('Please enter the password to your repository:')
      end

      def get_git_remote
        remotes = `git remote -v`.split("\n")
        remote = remotes.first
        if remote
          remote.split("\t")[1].split(" ")[0]
        end
      end

      def setup_capistrano
        puts "\nSetting up Capistrano"
        `capify .`
      end

      def show_read_me
        puts "\nWe are done!\n"
        puts "\nPlease run 'cap deploy:setup'\n to setup the server for deployment."
        puts "\nIf you want to deploy Alchemy the first time type:\ncap deploy:cold"
        puts "\nAfter the first deploy you just need to type:\ncap deploy"
      end

    end
  end
end
