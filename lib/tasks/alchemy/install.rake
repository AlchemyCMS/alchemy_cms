require 'thor'

class Alchemy::RoutesInjector < Thor
  include Thor::Actions

  def initialize; super; end

  no_tasks do
    def inject
      @mountpoint = ask "\nWhere do you want to mount Alchemy CMS? (/)"
      @mountpoint = "/" if @mountpoint.empty?
      sentinel = /\.routes\.draw do(?:\s*\|map\|)?\s*$/
      inject_into_file "./config/routes.rb", "\n  mount Alchemy::Engine => '#{@mountpoint}'\n", { :after => sentinel, :verbose => true }
    end
  end
end

namespace :alchemy do

  desc "Installs Alchemy CMS into your app."
  task :install do
    Rake::Task["db:create"].invoke
    Rake::Task["alchemy:install:migrations"].invoke
    Rake::Task["alchemy:mount"].invoke
    system("rails g alchemy:scaffold")
    Rake::Task["db:migrate"].invoke
    Rake::Task["alchemy:db:seed"].invoke
    puts <<-EOF

\\o/ Successfully installed Alchemy CMS \\o/

Now cd into your app folder and

1. Start your Rails server:

  rails server

2. Open your browser and enter the following URL:

  http://localhost:3000/#{@mountpoint}

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
    Alchemy::RoutesInjector.new.inject
  end

end
