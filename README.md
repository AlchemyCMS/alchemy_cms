Alchemy
=======

About
-----

Alchemy is a fully featured Web-CMS which beautifully integrates into rails.
For more Information please visit http://alchemy-app.com

Rails Version
-------------

Alchemy is not yet Rails 3 and Ruby 1.9.2 compatible. We strongly recommend Rails 2.3.9 and Ruby 1.8.7.

Install via Rails template:
---------------------------

We have a fancy Rails template that does all the installation stuff for you. You can find it here:

<http://github.com/tvdeyen/alchemy-rails-templates/>

Just enter:

        rails -d mysql -m http://github.com/tvdeyen/alchemy-rails-templates/raw/master/install_alchemy.rb YOUR_APP_NAME

into your terminal and follow the instructions displayed after the templates executes.

If you want to install Alchemy inside an existing Rails project, then follow these steps:
-----------------------------------------------------------------------------------------

1. In your Rails App folder enter:

        script/plugin install git://github.com/tvdeyen/alchemy.git

2. Then enter following lines into the config block of your config/environment.rb file

        config.gem 'acts_as_ferret', :version => '0.4.8.2'
        config.gem 'authlogic', :version => '>=2.1.2'
        config.gem 'awesome_nested_set', :version => '>=1.4.3'
        config.gem 'declarative_authorization', :version => '>=0.4.1'
        config.gem "fleximage", :version => ">=1.0.4"
        config.gem 'fast_gettext', :version => '>=0.4.8'
        config.gem 'gettext_i18n_rails', :version => '>=0.2.3'
        config.gem 'gettext', :lib => false, :version => '>=1.9.3'
        config.gem 'rmagick', :lib => "RMagick2", :version => '>=2.12.2'
        config.gem 'jk-ferret', :version => '>=0.11.8.2', :lib => 'ferret'
        config.gem 'will_paginate', :version => '2.3.15'
        config.gem 'mimetype-fu', :version => '>=0.1.2', :lib => 'mimetype_fu'
        config.autoload_paths += %W( vendor/plugins/alchemy/app/sweepers )
        config.autoload_paths += %W( vendor/plugins/alchemy/app/middleware )
        config.i18n.load_path += Dir[Rails.root.join('vendor/plugins/alchemy/config', 'locales', '*.{rb,yml}')]

3. Then install these plugins:

        script/plugin install git://github.com/rails/acts_as_list.git
        script/plugin install git://github.com/technoweenie/attachment_fu.git
        script/plugin install git://github.com/iain/i18n_label.git
        script/plugin install git://github.com/trevorrowe/tinymce_hammer.git
        script/plugin install git://github.com/delynn/userstamp.git

4. Then create your database and migrate:

        rake db:create
        rake db:migrate:alchemy

5. Copy Alchemy assets to public folder:

        rake alchemy:assets:copy:all

Resources
---------

* Homepage: <http://alchemy-app.com/>
* API Documentation: <http://api.alchemy-app.com/>
* Issue-Tracker and Wiki: <http://redmine.alchemy-app.com/>
* Sourcecode: <http://github.com/tvdeyen/alchemy/>

License
-------

* GPLv3: <http://www.gnu.org/licenses/gpl.html/>
