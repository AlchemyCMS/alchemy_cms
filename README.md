Alchemy CMS
===========

[![Build Status](https://secure.travis-ci.org/magiclabs/alchemy_cms.png)](http://travis-ci.org/magiclabs/alchemy_cms)
![Status](http://stillmaintained.com/magiclabs/alchemy_cms.png)

About
-----

Features
--------

- Highly flexible Templating:
  - Content is stored in small parts not as a complete, monolithic page
  - The designer chooses the template structure, not the CMS!
  - Every Design is possible, no templating, or theming restrictions
  - Even Flash® Content Management is possible
- Gorgious End-User centric interface:
  - No markup editors
- Multilingual:
  - Create as many (complete independent) language trees as you want
  - URL based language switching
- SEO
  - Every Part of SEO is manageable by the user
  - Human readable urls (multilingual)
  - automatic XML Sitemap generation
- Access Control:
  - Rolebased Authentification (RBAS)
  - Protect pages for restricted access
- Fulltext Search
- RSS Feeds
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
  - BSD License
  - No Enterprise Licences, or Community Editions
- Hostable on any Server that supports RubyOnRails and ImageMagick ([Software Requirements](https://github.com/magiclabs/alchemy_cms/wiki/Software-Requirements))

Rails Version
-------------

This branch of Alchemy runs with Rails 3.1.3.

If you are looking for a Rails 3 compatible version check the rails-3 branch.

If you are looking for a Rails 2 compatible version check the rails-2 branch.

Ruby Version
------------

Alchemy under Ruby 1.8.7, Ruby 1.9.2, Ruby 1.9.3 and REE (Ruby Enterprise Edition).

Installation
------------

Use the installer (recommended):

    gem install alchemy_cms
    alchemy new my_magicpage

Start the local server:

    rails server

Then just switch to your browser and open `http://localhost:3000`

Upgrading
------------

Projects running with Alchemy CMS version < 2.1 needs to be upgraded.

Otherwise errors will be raised like this:
`uninitialized constant EssenceText`

You have to use the following Upgrade-Task.
Run in terminal:

    rake alchemy:upgrade


Add to existing Rails project
-----------------------------

In your Gemfile:

    gem 'alchemy_cms', '~> 2.1'

Run in terminal:

    bundle install
    rake alchemy:install:migrations
    rake db:migrate
    rake alchemy:db:seed

Tipps
-----

1. This generator creates all necessary folders and files needed for creating your own page layouts and elements for your website:

        rails generate alchemy:scaffold

2. If you use the ferret full text search (enabled by default), then please add a job to your crontab that reindexes the ferret index.

        cd /path/to/your/alchemy && RAILS_ENV=production rake ferret:rebuild_index > /dev/null

3. You can easily create your element files (for view and editor) depending on the `elements.yml` with this generator:

        rails generate elements

Resources
---------

* Homepage: <http://alchemy-cms.com>
* Live-Demo: <http://demo.alchemy-cms.com> (user: demo, password: demo)
* Wiki: <http://wiki.alchemy-cms.com>
* API Documentation: <http://api.alchemy-cms.com>
* Issue-Tracker: <http://issues.alchemy-cms.com>
* Sourcecode: <http://source.alchemy-cms.com>
* User Group: <http://groups.google.com/group/alchemy-cms>

Authors
---------

* Thomas von Deyen: <https://github.com/tvdeyen>
* Robin Böning: <https://github.com/robinboening>
* Marc Schettke: <https://github.com/masche842>
* Carsten Fregin: <https://github.com/cfregin>

License
-------

* BSD: <https://raw.github.com/magiclabs/alchemy_cms/master/LICENSE>
