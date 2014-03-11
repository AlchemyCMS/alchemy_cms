require 'thor'

class Alchemy::InstallTask < Thor
  include Thor::Actions

  no_tasks do
    def inject_routes
      mountpoint = ask "\nAt which path do you want to mount Alchemy CMS at? (DEFAULT: At root path '/')"
      mountpoint = "/" if mountpoint.empty?
      sentinel = /\.routes\.draw do(?:\s*\|map\|)?\s*$/
      inject_into_file "./config/routes.rb", "\n  mount Alchemy::Engine => '#{mountpoint}'\n", { after: sentinel, verbose: true }
    end

    def set_primary_language
      code = ask "\nWhat's the language code of your site's primary language? (DEFAULT: en)"
      code = "en" if code.empty?
      name = ask "What's the name of your site's primary language? (DEFAULT: English)"
      name = "English" if name.empty?
      gsub_file "./config/alchemy/config.yml", /default_language:\n\s\scode:\sen\n\s\sname:\sEnglish/m do |match|
        match = "default_language:\n  code: #{code}\n  name: #{name}"
      end
    end
  end

end

namespace :alchemy do

  desc "Installs Alchemy CMS into your app."
  task :install do
    puts "\nAlchemy Installer"
    puts "-----------------"
    Rake::Task["alchemy:mount"].invoke
    system('rails g alchemy:scaffold') || exit!(1)
    Alchemy::InstallTask.new.set_primary_language
    Rake::Task["db:create"].invoke
    Rake::Task["alchemy:install:migrations"].invoke
    Rake::Task["db:migrate"].invoke
    Rake::Task["alchemy:db:seed"].invoke
    puts "\nAlchemy successfully installed."
    puts "\nNow start the server with:"
    puts "\n$ bin/rails server"
    puts "\nand point your browser to http://localhost:3000/admin and follow the onscreen instructions to finalize the installation."
  end

  desc "Mounts Alchemy into your routes."
  task :mount do
    Alchemy::InstallTask.new.inject_routes
  end

end
