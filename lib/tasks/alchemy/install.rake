require 'thor'

class Alchemy::RoutesInjector < Thor
  include Thor::Actions

  no_tasks do
    def inject
      mountpoint = ask "\nWhere do you want to mount Alchemy CMS? (/)"
      mountpoint = "/" if mountpoint.empty?
      sentinel = /\.routes\.draw do(?:\s*\|map\|)?\s*$/
      inject_into_file "./config/routes.rb", "\n  mount Alchemy::Engine => '#{mountpoint}'\n", { :after => sentinel, :verbose => true }
      mountpoint
    end
  end

end

namespace :alchemy do

  desc "Creates, migrates and seeds the database to run Alchemy."
  task :prepare => ["db:create", "alchemy:install:migrations", "db:migrate", "alchemy:db:seed"]

  desc "Installs Alchemy CMS into your app."
  task :install => ["alchemy:prepare", "alchemy:mount"] do
    system("rails g alchemy:scaffold")
    puts <<-EOF

\\o/ Successfully installed Alchemy CMS \\o/

Now cd into your app folder and

1. Start your Rails server:

  rails server

2. Open your browser and enter the following URL:

  http://localhost:3000/#{@mountpoint.gsub(/\A\//, '')}

3. Follow the instructions to complete the installation!

== First time Alchemy user?

Then we recommend to install the Alchemy demo kit.

Just add `gem "alchemy-demo_kit"` to your apps Gemfile and run `bundle install`.

Thank you for using Alchemy CMS!

http://alchemy-cms.com/

EOF
  end

  desc "Mounts Alchemy into your routes."
  task :mount do
    @mountpoint = Alchemy::RoutesInjector.new.inject
  end

end
