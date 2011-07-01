Alchemy
=======

About the content management system
-----

Alchemy is a fullly featured, content management system, which beautifully integrates into rails.

Nearly every content management system stores the content of a page in a body column in the pages table. This is easy to develop and the user manages the content inside one of the fancy new Javascript based wysiwyg processors. Formatting, image placement, styling and positioning of the content is in the hand of the end-user.

__We think this is completly wrong!__

The content manager mustn‘t be able to change anything but the content and some basic text formatting. The content manager shouldn‘t care about headline formatting, image positioning or resizing. The developer should take care of this!

__Alchemy is different!__

We split the page into logical parts like headlines, paragraphs, images, etc. The only thing we store in  the database is text: ids of images and richtext content. Nothing else. No markup (besides basic text formatting inside the richtext elements), no styling, no layout. Pure content!

This gives the webdeveloper the power and flexibility to implement any kind of layout with the insurance that the content manager is not able to break up the layout.

Rails Version
-------------

We strongly recommend Rails 2.3.10 and Ruby 1.8.7.

We are working hard on a Rails 3 compatible Gem of Alchemy. Feel free to contribute :) Just fork the rails3 branch.

Install via Rails template:
---------------------------

We have a fancy Rails template that does all the installation stuff for you. You can find it here:

<http://github.com/magiclabs/alchemy-rails-templates/>

Download the template and put it in a folder of your choice of your local disc.

Then enter:

        rails _2.3.10_ -d mysql -m path/to/template/install_alchemy.rb YOUR_APP_NAME

After creation of the new project, follow the instructions displayed in the console.
Then just switch to your browser and open http://localhost:3000/admin for creating your first admin user.

If you want to install Alchemy inside an existing Rails project, then follow these steps:
-----------------------------------------------------------------------------------------

1. In your Rails App folder enter:

        script/plugin install git://github.com/magiclabs/alchemy.git

2. Then enter following lines into the config block of your config/environment.rb file

        config.gem 'acts_as_ferret', :version => '0.4.8.2'
        config.gem 'authlogic', :version => '~>2'
        config.gem 'awesome_nested_set', :version => '>=1.4.3'
        config.gem 'declarative_authorization', :version => '>=0.4.1'
        config.gem "fleximage", :version => ">=1.0.4"
        config.gem 'fast_gettext', :version => '>=0.4.8'
        config.gem 'gettext_i18n_rails', :version => '~>0.2'
        config.gem 'gettext', :lib => false, :version => '>=1.93.0'
        config.gem 'rmagick', :lib => "RMagick2", :version => '>=2.12.2'
        config.gem 'jk-ferret', :version => '>=0.11.8.2', :lib => 'ferret'
        config.gem 'will_paginate', :version => '~>2.3'
        config.gem 'mimetype-fu', :version => '>=0.1.2', :lib => 'mimetype_fu'
        config.autoload_paths += %W( vendor/plugins/alchemy/app/sweepers )
        config.autoload_paths += %W( vendor/plugins/alchemy/app/middleware )
        config.i18n.load_path += Dir[Rails.root.join('vendor/plugins/alchemy/config', 'locales', '*.{rb,yml}')]

3. Then install these plugins:

        script/plugin install git://github.com/rails/acts_as_list.git
        script/plugin install git://github.com/technoweenie/attachment_fu.git
        script/plugin install git://github.com/iain/i18n_label.git
        script/plugin install git://github.com/aaronchi/jrails.git
        script/plugin install -r rails2 git://github.com/tvdeyen/tinymce_hammer.git
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

A few hints for the beginning
-----------------------------

1. This task creates all necessary folders and files needed for creating your own pagelayouts and elements for your website

        rake alchemy:app_structure:create:all

2. If you use the ferret full text search (enabled by default), then please add a job to your crontab that reindexes the ferret index.

        cd /path/to/your/alchemy && RAILS_ENV=production rake ferret:rebuild_index

3. You can easily create your element-files (for view and editor) depending on the elements.yml with this generator

        script/generate elements

Resources
---------

* Homepage: <http://alchemy-app.com>
* Live-Demo: <http://demo.alchemy-app.com>
* Wiki: <http://wiki.alchemy-app.com>
* API Documentation: <http://api.alchemy-app.com>
* Issue-Tracker: <http://issues.alchemy-app.com>
* Sourcecode: <http://source.alchemy-app.com>
* User Group: <http://groups.google.com/group/alchemy-cms>

Authors
---------

* Carsten Fregin: <https://github.com/cfregin>
* Thomas von Deyen: <https://github.com/tvdeyen>
* Robin Böning: <https://github.com/robinboening>

License
-------

* GPLv3: <http://www.gnu.org/licenses/gpl.html/>
