![Alchemy CMS](http://alchemy-cms.com/assets/alchemy_logo.png)

[![Build Status](https://secure.travis-ci.org/magiclabs/alchemy_cms.png?branch=master)](http://travis-ci.org/magiclabs/alchemy_cms) [![Dependency Status](https://gemnasium.com/magiclabs/alchemy_cms.png)](https://gemnasium.com/magiclabs/alchemy_cms) [![Code Climate](https://codeclimate.com/github/magiclabs/alchemy_cms.png)](https://codeclimate.com/github/magiclabs/alchemy_cms)

About
-----
**This branch is a beta development branch. For productive environments use the current rubygems version, or the [latest stable branch (2.5-stable)](https://github.com/magiclabs/alchemy_cms/tree/2.5-stable).**

Alchemy is a powerful, userfriendly and flexible Rails 3 CMS.

Read more on the [website](http://alchemy-cms.com) and in the [guidelines](http://guides.alchemy-cms.com).

Features
--------

- Highly flexible Templating
- Gorgious End-User centric interface
- Multilingual
- Multidomain
- SEO friendly
- Access Control
- Fulltext Search
- RSS Feeds
- Contactforms
- Attachments and downloads
- Powerful image rendering
- Extendable
- Integrates in existing Rails Apps
- Caching
- BSD License
- Hostable on any Server that supports Ruby on Rails, a SQL Database and ImageMagick

Rails Version
-------------

This version of Alchemy runs with Rails 3.2.11+.

If you are looking for a Rails 3.1 compatible version check the [2.1-stable branch](https://github.com/magiclabs/alchemy_cms/tree/2.1-stable).

If you are looking for a Rails 3.0 compatible version check the [2.0-stable branch](https://github.com/magiclabs/alchemy_cms/tree/2.0-stable).

If you are looking for a Rails 2.3 compatible version check the [1.6-stable branch](https://github.com/magiclabs/alchemy_cms/tree/1.6-stable).

Ruby Version
------------

Alchemy runs with Ruby 1.9.2 and Ruby 1.9.3 only.

For a Ruby 1.8.7 compatible version use the [2.3-stable branch](https://github.com/magiclabs/alchemy_cms/tree/2.3-stable).

Installation
------------

Use the installer (recommended):

    gem install alchemy_cms
    alchemy new my_magicpage
    cd my_magicpage

Start the local server:

    rails server

Then just switch to your browser and open `http://localhost:3000`

Add to existing Rails project
-----------------------------

In your Gemfile:

    gem 'alchemy_cms', github: 'magiclabs/alchemy_cms', branch: 'master'

Run in terminal:

    bundle install
    bundle exec rake alchemy:install

### Note:
If you did not mounted Alchemy on the root route `'/'`, then you have to add Alchemy's view helpers manually to your app.

Just paste this in your `app/controllers/application_controller.rb`

```
helper Alchemy::PagesHelper
```

Upgrading
---------

After updating Alchemy you should run the upgrader.

Run in terminal:

    bundle exec rake alchemy:upgrade


Tipps
-----

- Read the guidelines: http://guides.alchemy-cms.com.
- Read the documentation: http://rubydoc.info/github/magiclabs/alchemy_cms
- Ask the community: http://groups.google.com/group/alchemy-cms


Resources
---------

* Homepage: <http://alchemy-cms.com>
* Live-Demo: <http://demo.alchemy-cms.com> (user: demo, password: demo)
* API Documentation: <http://rubydoc.info/github/magiclabs/alchemy_cms>
* Issue-Tracker: <https://github.com/magiclabs/alchemy_cms/issues>
* Sourcecode: <https://github.com/magiclabs/alchemy_cms>
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
