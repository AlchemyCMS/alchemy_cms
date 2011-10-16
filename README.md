Alchemy CMS
===========

[![Build Status](https://secure.travis-ci.org/magiclabs/alchemy_cms.png)](http://travis-ci.org/magiclabs/alchemy_cms)

About
-----

Alchemy is a fully featured Content Management System (CMS) with an gorgeous Userinterface.

Nearly every content management system stores the content of a page in a body column in the pages table. This is easy to develop and the user manages the content inside one of the fancy new Javascript based wysiwyg processors. Formatting, image placement, styling and positioning of the content is in the hand of the end-user.

__We think this is completly wrong!__

The content manager mustn‘t be able to change anything but the content and some basic text formatting. The content manager shouldn‘t care about headline formatting, image positioning or resizing. The developer should take care of this!

__Alchemy is different!__

We split the page into logical parts like headlines, paragraphs, images, etc. The only thing we store in  the database is text: ids of images and richtext content. Nothing else. No markup (besides basic text formatting inside the richtext elements), no styling, no layout. Pure content!

This gives the webdeveloper the power and flexibility to implement any kind of layout with the insurance that the content manager is not able to break up the layout.

Features
--------

- Highly flexible Templating:
  - Content is stored in small parts not as a complete, monolithic page.
  - The designer chooses the template structure, not the CMS!
  - Every Design is possible, no templating, or theming restrictions.
  - Even Flash® Content Management is possible
- Gorgious End-User centric interface:
  - No geeky markup editors and other meta programming crap.
- Multilingual:
  - Create as many (complete independent) language trees as you want.
  - URL based language switching
- SEO
  - Every Part of SEO is manageable by the user
  - Human readable urls (multilingual)
  - automatic XML Sitemap generation
- Access Control:
  - Rolebased Authentification (RBAS)
  - Protect pages for restricted access
- Fulltext Search
- Contactforms
- Attachments and downloads
- Powerfull image rendering
  - Resizing
  - Image Cropping via an graphical Userinterface!
  - Borders, Text, Rotation
  - and much more via Imagemagick processing (polaroid effect, etc.)
  - and all this gets cached!
- Extendable:
  - Flexible Plugin DSL allows you to add custom plugins into Alchemy
- Integrates in exsiting Rails Apps
- Caching
- Completely free:
  - GPLv3 License
  - No Enterprise Licences, or Community Editions
- Hostable on any Server that supports RubyOnRails and ImageMagick ([Software Requirements](https://github.com/magiclabs/alchemy/wiki/Software-Requirements))

Rails Version
-------------

This branch of Alchemy runs with Rails 3.0.9 and Ruby 1.8.7. __Ruby 1.9 is not__ offically supported yet, because not all Gems Alchemy depends on are Ruby 1.9 ready.

Installation
------------

Use the installer (recommended):

    gem install alchemy_cms
    alchemy new my_magicpage

Start the local server:

    rails server

Then just switch to your browser and open `http://localhost:3000`.

Add to existing Rails project:

    add gem 'alchemy_cms' to Gemfile

    bundle install
    rake alchemy:prepare
    rake alchemy:standard_set:install (optional)
    rake db:migrate


Tipps
-----

1. This task creates all necessary folders and files needed for creating your own pagelayouts and elements for your website

        rake generate alchemy:scaffold:all

2. If you use the ferret full text search (enabled by default), then please add a job to your crontab that reindexes the ferret index.

        cd /path/to/your/alchemy && RAILS_ENV=production rake ferret:rebuild_index > /dev/null

3. You can easily create your element-files (for view and editor) depending on the `elements.yml` with this generator

        rails generate elements

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
