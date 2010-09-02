Alchemy
=======

About
-----

Alchemy is a fully featured Web-CMS which beautifully integrates into rails.
For more Information please visit http://alchemy-app.com

Install
-------

Unless we have a installscript (cooming soon...) you have to do following steps to install Alchemy:

1. In your Rails App folder enter:

        script/plugin install git://github.com/tvdeyen/alchemy.git

2. Then enter following lines into your config/environment.rb file

    * Inside the config block:

            config.gem 'acts_as_ferret', :version => '>=0.4.8'
            config.gem 'authlogic', :version => '>=2.1.2'
            config.gem 'awesome_nested_set', :version => '>=1.4.3'
            config.gem 'declarative_authorization', :version => '>=0.4.1'
            config.gem "fleximage", :version => ">=1.0.1"
            config.gem 'fast_gettext', :version => '>=0.4.8'
            config.gem 'gettext_i18n_rails', :version => '>=0.2.3'
            config.gem 'gettext', :lib => false, :version => '>=1.9.3'
            config.gem 'rmagick', :lib => "RMagick2", :version => '>=2.12.2'
            config.gem 'tvdeyen-ferret', :version => '>=0.11.8.1', :lib => 'ferret'
            config.gem 'will_paginate', :version => '>=2.3.12'
            config.load_paths += %W( #{RAILS_ROOT}/vendor/plugins/alchemy/app/sweepers )
            config.load_paths += %W( #{RAILS_ROOT}/vendor/plugins/alchemy/app/middleware )
            config.i18n.load_path += Dir[Rails.root.join('vendor/plugins/alchemy/config', 'locales', '*.{rb,yml}')]

3. Then install these plugins:

        script/plugin install git://github.com/rails/acts_as_list.git
        script/plugin install git://github.com/tvdeyen/alchemy.git
        script/plugin install git://github.com/sbecker/asset_packager.git
        script/plugin install git://github.com/technoweenie/attachment_fu.git
        script/plugin install git://github.com/iain/i18n_label.git
        script/plugin install git://github.com/trevorrowe/tinymce_hammer.git
        script/plugin install git://github.com/delynn/userstamp.git
        script/plugin install git://github.com/mattetti/mimetype-fu.git

4. Then create your database and migrate:

        rake db:create
        rake db:migrate:alchemy

Resources
---------

* Homepage: <http://alchemy-app.com/>
* API Documentation: <http://api.alchemy-app.com/>
* Issue-Tracker and Wiki: <http://redmine.alchemy-app.com/>
* Sourcecode: <http://github.com/tvdeyen/alchemy/>

License
-------

* GPLv3: <http://www.gnu.org/licenses/gpl.html/>
