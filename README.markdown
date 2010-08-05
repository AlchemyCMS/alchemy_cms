Alchemy
=======

About
-----

Alchemy is a fully featured Web-CMS which beautifully integrates into rails.
For more Information please visit http://alchemy-app.com

Install
-------

Unless we have a installscript (cooming soon ^_^) you have to do following steps to install Alchemy:

1. In your Rails App folder enter:

    script/plugin install git://github.com/tvdeyen/Alchemy.git

2. Then enter folowing lines into your config/environment.rb file

* Before the config block:

    require File.join(File.dirname(__FILE__), '../vendor/plugins/alchemy/plugins/engines/boot')

* In the config block:

    config.gem 'ferret'
    config.gem "grosser-fast_gettext", :version => '>=0.4.8', :lib => 'fast_gettext', :source => "http://gems.github.com" 
    config.gem "gettext", :lib => false, :version => '>=1.9.3'
    config.gem "rmagick", :lib => "RMagick2" 
    config.gem 'mime-types', :lib => "mime/types" 
    
    config.plugin_paths << File.join(File.dirname(__FILE__), '../vendor/plugins/alchemy/plugins')
    config.plugins = [ :declarative_authorization, :alchemy, :all ]
    config.load_paths += %W( #{RAILS_ROOT}/vendor/plugins/alchemy/app/sweepers )
    config.load_paths += %W( #{RAILS_ROOT}/vendor/plugins/alchemy/app/middleware )
    config.i18n.load_path += Dir[Rails.root.join('vendor/plugins/alchemy/config', 'locales', '*.{rb,yml}')]
    config.i18n.default_locale = :de
    config.active_record.default_timezone = :berlin

3. Place a alchemy_plugin_tasks.rake file in the lib/tasks folder with:

    # Make all the Alchemy plugins tasks available
    Dir.glob(File.dirname(__FILE__) + "/../../vendor/plugins/alchemy/plugins/**/tasks/*.rake").each do |rake_file|
      import rake_file
    end

4. Then create your database and migrate:

    rake db:create
    rake db:migrate
    rake db:migrate:plugins

Documentation
-------------

http://api.alchemy-app.com

Issue-Tracker and Wiki
----------------------

http://redmine.alchemy-app.com

Sourecode
---------

http://github.com/tvdeyen/alchemy

License
-------

GPLv3

http://www.gnu.org/licenses/gpl.html
