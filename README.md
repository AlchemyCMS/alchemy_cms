[![Gem Version](https://badge.fury.io/rb/alchemy_cms.svg)](http://badge.fury.io/rb/alchemy_cms)
[![Build Status](https://travis-ci.org/AlchemyCMS/alchemy_cms.svg?branch=3.0-stable)](https://travis-ci.org/AlchemyCMS/alchemy_cms) [![Code Climate](https://codeclimate.com/github/AlchemyCMS/alchemy_cms.svg)](https://codeclimate.com/github/AlchemyCMS/alchemy_cms) [![Coverage Status](https://img.shields.io/coveralls/AlchemyCMS/alchemy_cms.svg)](https://coveralls.io/r/AlchemyCMS/alchemy_cms?branch=3.0-stable)

About
-----

![Alchemy CMS](http://alchemy-cms.com/assets/alchemy_logo.svg)

Alchemy is the most powerful, userfriendly and flexible Rails CMS.

Read more on the [website](http://alchemy-cms.com) and in the [guidelines](http://guides.alchemy-cms.com).

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

If you are looking for a Rails 3.2 compatible version check the [2.8-stable branch](https://github.com/AlchemyCMS/alchemy_cms/tree/2.8-stable).

If you are looking for a Rails 3.1 compatible version check the [2.1-stable branch](https://github.com/AlchemyCMS/alchemy_cms/tree/2.1-stable).

If you are looking for a Rails 3.0 compatible version check the [2.0-stable branch](https://github.com/AlchemyCMS/alchemy_cms/tree/2.0-stable).

If you are looking for a Rails 2.3 compatible version check the [1.6-stable branch](https://github.com/AlchemyCMS/alchemy_cms/tree/1.6-stable).

Ruby Version
------------

Alchemy runs with Ruby >= 1.9.3 (including Ruby 2.0 and 2.1).

For a Ruby 1.8.7 compatible version use the [2.3-stable branch](https://github.com/AlchemyCMS/alchemy_cms/tree/2.3-stable).


Installation
------------

### Translation requirements

#### Russian:

If you want to use Russian translation and have better i18n support, you should put:

    gem 'russian', '~> 0.6.0'

or similar in functionality gem into your Gemfile before running:

    bundle install

### As a standalone project

#### 1. Use the installer:

    gem install alchemy_cms
    alchemy new my_magicpage
    cd my_magicpage

Run

    bundle install

to finish installation process.

#### 2. Start the local server:

    bin/rails server

#### 3. Switch to your browser:

Open `http://localhost:3000` and follow the on screen instructions.

### Into an existing Rails project

#### 1. Add the Alchemy gem:

In your App's Gemfile:

    gem 'alchemy_cms', github: 'AlchemyCMS/alchemy_cms', branch: '3.0-stable'

#### 2. Install Alchemy into your app:

Run in terminal:

    bundle install
    bin/rake alchemy:install

### Authentication User Model

With Version 3.0 we extracted the Alchemy user model [into its own gem](https://github.com/AlchemyCMS/alchemy-devise).

In order to get the former Alchemy user model back, add the following gem into your Gemfile:

    gem 'alchemy-devise', '~> 2.0'

Run in terminal:

    bundle install
    bin/rake alchemy_devise:install:migrations db:migrate

**In order to use your own user model, you can add e.g.**

    # config/initializers/alchemy.rb
    Alchemy.user_class_name = 'YourUserClass'
    Alchemy.login_path = '/your/login/path'
    Alchemy.logout_path = '/your/logout/path'

The only thing Alchemy needs to know from your user model is the `alchemy_roles` method.

This method has to return an `Array` or `ActiveRecord::Relation` with at least one of the following roles:

* `member`
* `author`
* `editor`
* `admin`

Example:

    def alchemy_roles
      self.admin?
        %w(admin)
      end
    end

**Optionally** you can add a `alchemy_display_name` method that returns a name representing the currently logged in user. This is used in the admin views.

Example:

    def alchemy_display_name
      "#{first_name} #{last_name}".strip
    end

Testing
-------

Before running tests (which refer to Alchemy), please make sure to run the rake task

    bundle exec rake alchemy:spec:prepare

to set up the database for testing.

Now you can run your tests, e. g. with RSpec:

    bundle exec rspec spec/...

**Alternatively** you can just run:

    bundle exec rake

This default task executes the database preparations and runs all defined test cases.

Deployment
----------

Alchemy ships with a generator that creates a Capistrano `config/deploy.rb` file, which
takes care of everything you need to deploy an Alchemy site.

So, if you don't have your own deploy file, we encourage you to use this generator:

    $ bin/rails g alchemy:deploy_script

If you have your own Capistrano receipts, you should require the Alchemy tasks in your app's `config/deploy.rb` file:

    # deploy.rb
    require 'alchemy/capistrano'

If you don't use Capistrano you have to **make sure that the `uploads`, `tmp/cache/assets`, `public/assets` and `public/pictures` cache folders get shared** between deployments, otherwise you **will loose data**.

Please take a look into the `lib/alchemy/capistrano.rb` file, to see how to achieve this.

Upgrading
---------

After updating the Alchemy gem in your App, you should run the upgrader.

Run in terminal:

    bin/rake alchemy:upgrade


Tips
-----

- Read the guidelines: http://guides.alchemy-cms.com.
- Read the documentation: http://rubydoc.info/github/AlchemyCMS/alchemy_cms
- Ask the community: http://groups.google.com/group/alchemy-cms


Getting Help
------------

* If you have bugs, please use the [issue tracker on Github](https://github.com/AlchemyCMS/alchemy_cms/issues).
* For Q&A and general usage, please use the [User Group](http://groups.google.com/group/alchemy-cms) or the IRC channel.
* New features should be discussed on our [Trello Board](https://trello.com/alchemycms). *PLEASE* don't use the Github issues for new features.


Resources
---------

* Homepage: <http://alchemy-cms.com>
* Live-Demo: <http://demo.alchemy-cms.com> (user: demo, password: demo123)
* API Documentation: <http://rubydoc.info/github/AlchemyCMS/alchemy_cms>
* Issue-Tracker: <https://github.com/AlchemyCMS/alchemy_cms/issues>
* Sourcecode: <https://github.com/AlchemyCMS/alchemy_cms>
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

* BSD: <https://raw.github.com/AlchemyCMS/alchemy_cms/master/LICENSE>
