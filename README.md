Alchemy
=======

About
-----

Alchemy is a fully featured Web-CMS which beautifully integrates into rails.
For more Information please visit <http://magiclabs.github.com/alchemy>

Rails Version
-------------

Alchemy is not yet Rails 3 and Ruby 1.9.2 compatible. We strongly recommend Rails 2.3.10 and Ruby 1.8.7.

Install via Rails template:
---------------------------

We have a fancy Rails template that does all the installation stuff for you. You can find it here:

<http://github.com/magiclabs/alchemy-rails-templates/>

Download the template and put it in a folder of your choice of your local disc.

Then enter:

        rails _2.3.10_ -d mysql -m path/to/template/install_alchemy.rb YOUR_APP_NAME

into your terminal and follow the instructions displayed after the templates executes.

If you want to install Alchemy inside an existing Rails project, then follow these steps:
-----------------------------------------------------------------------------------------

1. In your Rails App folder enter:

        script/plugin install git://github.com/magiclabs/alchemy.git

2. Then enter following lines into the config block of your config/environment.rb file

        config.gem 'acts_as_ferret', :version => '0.4.8.2'
        config.gem 'authlogic', :version => '>=2.1.2'
        config.gem 'awesome_nested_set', :version => '>=1.4.3'
        config.gem 'declarative_authorization', :version => '>=0.4.1'
        config.gem "fleximage", :version => ">=1.0.4"
        config.gem 'fast_gettext', :version => '>=0.4.8'
        config.gem 'gettext_i18n_rails', :version => '0.2.3'
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
        script/plugin install git://github.com/aaronchi/jrails.git
        script/plugin install git://github.com/trevorrowe/tinymce_hammer.git
        script/plugin install git://github.com/delynn/userstamp.git

4. Then create your database and migrate:

        rake db:create
        rake db:migrate:alchemy

5. Put this to your db/seeds.rb to create the page tree structure:

        Alchemy::Seeder.seed!

6. And seed the database:

        rake db:seed

7. Copy Alchemy assets to public folder:

        rake alchemy:assets:copy:all

Tip
---

If you use the ferret full text search (enabled by default), then please add a job to your crontab that reindexes the ferret index.

Example:

        cd /path/to/your/alchemy && RAILS_ENV=production rake ferret:rebuild_index

Resources
---------

* Homepage: <http://magiclabs.github.com/alchemy/>
* Issue-Tracker: <http://alchemy.lighthouseapp.com/projects/73309-alchemy-cms>
* Wiki: <https://github.com/magiclabs/alchemy/wiki>
* Sourcecode: <https://github.com/magiclabs/alchemy>

Authors
---------

* Carsten Fregin: <https://github.com/cfregin>
* Thomas von Deyen: <https://github.com/tvdeyen>
* Robin Böning: <https://github.com/robinboening>

License
-------

* GPLv3: <http://www.gnu.org/licenses/gpl.html/>
