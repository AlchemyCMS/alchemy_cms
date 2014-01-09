![Alchemy CMS](http://alchemy-cms.com/assets/alchemy_logo.png)

[![Gem Version](https://badge.fury.io/rb/alchemy_cms.png)](http://badge.fury.io/rb/alchemy_cms)
[![Build Status](https://secure.travis-ci.org/magiclabs/alchemy_cms.png?branch=master)](http://travis-ci.org/magiclabs/alchemy_cms) [![Code Climate](https://codeclimate.com/github/magiclabs/alchemy_cms.png)](https://codeclimate.com/github/magiclabs/alchemy_cms) [![Coverage Status](https://coveralls.io/repos/magiclabs/alchemy_cms/badge.png?branch=master)](https://coveralls.io/r/magiclabs/alchemy_cms?branch=master)

About
-----

Alchemy is the most powerful, userfriendly and flexible Rails CMS.

Read more on the [website](http://alchemy-cms.com) and in the [guidelines](http://guides.alchemy-cms.com).

**This master branch is a development branch that can contain bugs. For productive environments you should use the [current Ruby gem version](http://rubygems.org/gems/alchemy_cms/versions/2.7.1),
or the [latest stable branch (2.7-stable)](https://github.com/magiclabs/alchemy_cms/tree/2.7-stable).**

Features
--------

- Highly flexible Templating
- Gorgious End-User centric interface
- Multilingual
- Multidomain
- SEO friendly
- Access Control
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

**This version of Alchemy CMS runs with Rails 4 (including 4.1)**

If you are looking for a Rails 3.2 compatible version check the [2.7-stable branch](https://github.com/magiclabs/alchemy_cms/tree/2.7-stable).

If you are looking for a Rails 3.1 compatible version check the [2.1-stable branch](https://github.com/magiclabs/alchemy_cms/tree/2.1-stable).

If you are looking for a Rails 3.0 compatible version check the [2.0-stable branch](https://github.com/magiclabs/alchemy_cms/tree/2.0-stable).

If you are looking for a Rails 2.3 compatible version check the [1.6-stable branch](https://github.com/magiclabs/alchemy_cms/tree/1.6-stable).

Ruby Version
------------

Alchemy runs with Ruby >= 1.9.3 (including Ruby 2.0.0).

For a Ruby 1.8.7 compatible version use the [2.3-stable branch](https://github.com/magiclabs/alchemy_cms/tree/2.3-stable).


Installation
------------

### As a standalone project.

#### 1. Use the installer:

    gem install alchemy_cms
    alchemy new my_magicpage
    cd my_magicpage

#### 2. Start the local server:

    rails server

#### 3. Switch to your browser:

Open `http://localhost:3000` and follow the on screen instructions.

### Into an existing Rails project

#### 1. Add the Alchemy gem:

In your App's Gemfile.

    gem 'alchemy_cms', github: 'magiclabs/alchemy_cms', branch: 'master'

#### 2. Install Alchemy into your app:

Run in terminal:

    bundle install
    bundle exec rake alchemy:install


Upgrading
---------

After updating the Alchemy gem in your App, you should run the upgrader.

Run in terminal:

    bundle exec rake alchemy:upgrade


Tipps
-----

- Read the guidelines: http://guides.alchemy-cms.com.
- Read the documentation: http://rubydoc.info/github/magiclabs/alchemy_cms
- Ask the community: http://groups.google.com/group/alchemy-cms


Getting Help
------------

* If you have bugs, please use the [issue tracker on Github](https://github.com/magiclabs/alchemy_cms/issues).
* For Q&A and general usage, please use the [User Group](http://groups.google.com/group/alchemy-cms) or the IRC channel.
* New features should be discussed on our [Trello Board](https://trello.com/alchemycms). *PLEASE* don't use the Github issues for new features.


Resources
---------

* Homepage: <http://alchemy-cms.com>
* Live-Demo: <http://demo.alchemy-cms.com> (user: demo, password: demo)
* API Documentation: <http://rubydoc.info/github/magiclabs/alchemy_cms>
* Issue-Tracker: <https://github.com/magiclabs/alchemy_cms/issues>
* Sourcecode: <https://github.com/magiclabs/alchemy_cms>
* User Group: <http://groups.google.com/group/alchemy-cms>
* IRC Channel: #alchemy_cms on irc.freenode.net
* Discussion Board: <https://trello.com/alchemycms>

Authors
---------

* Thomas von Deyen: <https://github.com/tvdeyen>
* Robin Böning: <https://github.com/robinboening>
* Marc Schettke: <https://github.com/masche842>
* Hendrik Mans: <https://github.com/hmans>
* Carsten Fregin: <https://github.com/cfregin>

License
-------

* BSD: <https://raw.github.com/magiclabs/alchemy_cms/2.7-stable/LICENSE>
