Alchemy CMS
===========

[![Build Status](https://secure.travis-ci.org/magiclabs/alchemy_cms.png?branch=master)](http://travis-ci.org/magiclabs/alchemy_cms)
[![Maintenance Status](http://stillmaintained.com/magiclabs/alchemy_cms.png)](http://stillmaintained.com/magiclabs/alchemy_cms)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/magiclabs/alchemy_cms)

About
-----

**This branch is a beta development branch. For productive environments use the current rubygems version, or the [latest stable branch (2.4-stable)](https://github.com/magiclabs/alchemy_cms/tree/2.4-stable).**

Alchemy is a powerful, userfriendly and flexible Rails 3 CMS.

Read more on the [website](http://alchemy-cms.com) and in the [guidelines](http://guides.alchemy-cms.com).

Features
--------

- Highly flexible Templating
- Gorgious End-User centric interface
- Multilingual
- SEO
- Access Control
- Fulltext Search
- RSS Feeds
- Contactforms
- Attachments and downloads
- Powerfull image rendering
- Extendable
- Integrates in exsiting Rails Apps
- Caching
- BSD License
- Hostable on any Server that supports RubyOnRails and ImageMagick ([Software Requirements](https://github.com/magiclabs/alchemy_cms/wiki/Software-Requirements))

Rails Version
-------------

This version of Alchemy runs with Rails 3.2.8+.

If you are looking for a Rails 3.1 compatible version check the [2.1-stable branch](https://github.com/magiclabs/alchemy_cms/tree/2.1-stable).

If you are looking for a Rails 3.0 compatible version check the [2.0-stable branch](https://github.com/magiclabs/alchemy_cms/tree/2.0-stable).

If you are looking for a Rails 2.3 compatible version check the [1.6-stable branch](https://github.com/magiclabs/alchemy_cms/tree/1.6-stable).

Ruby Version
------------

Alchemy runs with Ruby 1.9.2 and Ruby 1.9.3.

For a Ruby 1.8.7 compatible version use the [2.3-stable branch](https://github.com/magiclabs/alchemy_cms/tree/2.3-stable).

Installation
------------

Use the installer (recommended):

    gem install alchemy_cms --pre
    alchemy new my_magicpage

Start the local server:

    rails server

Then just switch to your browser and open `http://localhost:3000`

Upgrading
------------

After updating Alchemy you should run the upgrader.

Run in terminal:

    rake alchemy:upgrade


Add to existing Rails project
-----------------------------

In your Gemfile:

    gem 'alchemy_cms', :github => 'magiclabs/alchemy_cms'

Run in terminal:

    bundle update
    rake alchemy:install

Note: If you did not mounted Alchemy on the root route `'/'`, then you have to add Alchemy's view helpers manually to your app.

Just paste this in your `app/controllers/application_controller.rb`

`helper Alchemy::PagesHelper`

Tipps
-----

1. This generator creates all necessary folders and files needed for creating your own page layouts and elements for your website:

        rails generate alchemy:scaffold

2. If you use the ferret full text search (enabled by default), then please add a job to your crontab that reindexes the ferret index.

        cd /path/to/your/alchemy && RAILS_ENV=production rake ferret:rebuild_index > /dev/null

3. You can easily create your element files (for view and editor) depending on the `elements.yml` with this generator:

        rails generate alchemy:elements --skip

Resources
---------

* Homepage: <http://alchemy-cms.com>
* Live-Demo: <http://demo.alchemy-cms.com> (user: demo, password: demo)
* Wiki: <http://wiki.alchemy-cms.com>
* API Documentation: <http://api.alchemy-cms.com>
* Issue-Tracker: <http://issues.alchemy-cms.com>
* Sourcecode: <http://source.alchemy-cms.com>
* User Group: <http://groups.google.com/group/alchemy-cms>
* Changelog: <http://revision.io/alchemy_cms>

Authors
---------

* Thomas von Deyen: <https://github.com/tvdeyen>
* Robin Böning: <https://github.com/robinboening>
* Marc Schettke: <https://github.com/masche842>
* Hendrik Mans: <https://github.com/hmans>
* Carsten Fregin: <https://github.com/cfregin>

License
-------

* BSD: <https://raw.github.com/magiclabs/alchemy_cms/master/LICENSE>
