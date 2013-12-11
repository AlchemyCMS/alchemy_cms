require 'thor'

class Alchemy::RoutesInjector < Thor
  include Thor::Actions

  no_tasks do
    def inject
      mountpoint = ask "\nWhere do you want to mount Alchemy CMS? (DEFAULT: /)"
      mountpoint = "/" if mountpoint.empty?
      sentinel = /\.routes\.draw do(?:\s*\|map\|)?\s*$/
      inject_into_file "./config/routes.rb", "\n  mount Alchemy::Engine => '#{mountpoint}'\n", { after: sentinel, verbose: true }
    end
  end

end

namespace :alchemy do

  desc "Creates, migrates and seeds the database to run Alchemy."
  task prepare: ["db:create", "alchemy:install:migrations", "db:migrate", "alchemy:db:seed"]

  desc "Installs Alchemy CMS into your app."
  task install: ["alchemy:prepare", "alchemy:mount"] do
    system('rails g alchemy:scaffold') || exit!(1)
  end

  desc "Mounts Alchemy into your routes."
  task :mount do
    Alchemy::RoutesInjector.new.inject
  end

end
