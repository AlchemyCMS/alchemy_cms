[![Gem Version](https://badge.fury.io/rb/alchemy_cms.svg)](http://badge.fury.io/rb/alchemy_cms)
[![Build Status](https://travis-ci.org/AlchemyCMS/alchemy_cms.svg?branch=master)](https://travis-ci.org/AlchemyCMS/alchemy_cms) [![Code Climate](https://codeclimate.com/github/AlchemyCMS/alchemy_cms.svg)](https://codeclimate.com/github/AlchemyCMS/alchemy_cms) [![Coverage Status](https://img.shields.io/coveralls/AlchemyCMS/alchemy_cms.svg)](https://coveralls.io/r/AlchemyCMS/alchemy_cms?branch=master)

**CAUTION: This master branch is a development branch that can contain bugs. For productive environments you should use the [current Ruby gem version](https://rubygems.org/gems/alchemy_cms/versions/3.0.0), or the [latest stable branch (3.0-stable)](https://github.com/AlchemyCMS/alchemy_cms/tree/3.0-stable).**

About
-----

![Alchemy CMS](http://alchemy-cms.com/assets/alchemy_logo.svg)

Alchemy is a powerful, flexible and user centric Rails CMS.

Read more about Alchemy on the [website](http://alchemy-cms.com) and in the [guidelines](http://guides.alchemy-cms.com).

Features
--------

- Highly flexible templating that completely separates content from markup
- End-User centric graphical user interface
- Multi language and multi domain
- SEO friendly urls
- User Access Control
- Build in contact form mailer
- Attachments and downloads
- Powerful image rendering
- Extendable via Rails engines
- Integrates into existing Rails Apps
- Flexible caching
- Hostable on any Server that supports Ruby on Rails, a SQL Database and ImageMagick

Rails Version
-------------

**This version of Alchemy CMS runs with Rails 4 (including 4.1)**

**Rails 4.2 support is coming soon. Watch [this pull request](https://github.com/AlchemyCMS/alchemy_cms/pull/655).**

* For a Rails 3.2 compatible version use the [`2.8-stable` branch](https://github.com/AlchemyCMS/alchemy_cms/tree/2.8-stable).
* For a Rails 3.1 compatible version use the [`2.1-stable` branch](https://github.com/AlchemyCMS/alchemy_cms/tree/2.1-stable).
* For a Rails 3.0 compatible version use the [`2.0-stable` branch](https://github.com/AlchemyCMS/alchemy_cms/tree/2.0-stable).
* For a Rails 2.3 compatible version use the [`1.6-stable` branch](https://github.com/AlchemyCMS/alchemy_cms/tree/1.6-stable).

Ruby Version
------------

Alchemy runs with Ruby >= 1.9.3 (including Ruby 2.0 and 2.1).

For a Ruby 1.8.7 compatible version use the [`2.3-stable` branch](https://github.com/AlchemyCMS/alchemy_cms/tree/2.3-stable).


Installation
------------

### Install as a standalone project

Use the installer:

```shell
$ gem install alchemy_cms --pre
$ alchemy new my_magicpage
```

and follow the instructions to finish the installation.

The installer has some options (like choosing the database). See them with:

```shell
$ alchemy --help
```

### Install into an existing Rails project

#### 1. Add the Alchemy gem:

Put this into your `Gemfile`:

```ruby
gem 'alchemy_cms', github: 'AlchemyCMS/alchemy_cms', branch: 'master'
```

**NOTE:** You normally want to use a stable branch, like `3.0-stable`.

If you want to use Russian translation and have better i18n support, you should put:

```ruby
gem 'russian', '~> 0.6.0'
```

or gem with similar functionality into your Gemfile.

#### 2. Update your bundle:

```shell
$ bundle install
```

#### 3. Set the authentication user

Now you have to decide, if you want to use your own user model or if you want to use
the Devise based user model that Alchemy provides and was extracted [into its own gem](https://github.com/AlchemyCMS/alchemy-devise).

##### Use Alchemy user

If you don't have your own user class, you can use the Alchemy user model. Just add the following gem into your `Gemfile`:

```ruby
gem 'alchemy-devise', github: 'AlchemyCMS/alchemy-devise', branch: 'master'
```

**NOTE:** You normally want to use a stable branch, like `2.0-stable`.

Then run:

```shell
$ bundle install
$ bin/rake alchemy_devise:install:migrations
```

##### Use your User model

In order to use your own user model you need to tell Alchemy about it.

The best practice is to use an initializer:

```ruby
# config/initializers/alchemy.rb
Alchemy.user_class_name = 'YourUserClass'       # Defaults to 'User'
Alchemy.login_path      = '/your/login/path'    # Defaults to '/login'
Alchemy.logout_path     = '/your/logout/path'   # Defaults to '/logout'
```

The only thing Alchemy needs to know from your user class is the `alchemy_roles` method.

This method has to return an `Array` (or `ActiveRecord::Relation`) with at least one of the following roles: `member`, `author`, `editor`, `admin`.

Example:

```ruby
# app/models/user.rb

def alchemy_roles
  if admin?
    %w(admin)
  end
end
```

Please follow [this guide](http://guides.alchemy-cms.com/edge/custom_authentication.html) for further instructions on how to customize your user class even more.

#### 4. Install Alchemy into your app:

**After** you set the user model you need to run the Alchemy install task:

```shell
$ bin/rake alchemy:install
```

Now everything should be set up and you should be able to visit the Alchemy Dashboard at:

<http://localhost:3000/admin>

*) Use your custom path if you mounted Alchemy at something else then `'/'`


Customizing
-----------

Alchemy has very flexible ways to organize and manage content. Please be sure to read [the introduction guide](http://guides.alchemy-cms.com/edge/index.html) in order to understand the basic idea of how Alchemy works.


Upgrading
---------

The Alchemy team takes upgrades very seriously and tries to make them as smooth as we can. Therefore we have build in upgrade tasks, that try to automate as much as possible.

That's why after updating the Alchemy gem you should **always run the upgrader**:

```shell
$ bundle update alchemy_cms
$ bin/rake alchemy:upgrade
```

Alchemy will print out useful information after running the automated tasks that help a smooth upgrade path. So please **take your time and read them**.

Always be sure to keep an eye on the `config/alchemy/config.yml.defaults` file and update your `config/alchemy/config.yml` accordingly.

Also, `git diff` is your friend. You are using git to track changes of your projects, right?


Deployment
----------

Alchemy ships with Capistrano based deployment receipts which takes care of everything you need to deploy an Alchemy site.

#### Add Capistrano gem

First you need to add Capistrano to your `Gemfile`:

```ruby
# Gemfile
gem 'capistrano', '2.15.5', group: 'development'
```

**A note about Capistrano version:**

Alchemy's deploy script is currently **only compatible with Capistrano 2.x** ([See this pull request](https://github.com/AlchemyCMS/alchemy_cms/pull/616) if you want to help us upgrade to 3.x).

#### Generate the deploy file

To generate the deploy file you need to use this generator:

```shell
$ bin/rails g alchemy:deploy_script
```

and follow the instructions.

If you *have your own Capistrano receipts* you can require the Alchemy tasks in your `config/deploy.rb` file:

```ruby
# deploy.rb
require 'alchemy/capistrano'
```

#### Synchronize your data

Alchemy Capistrano receipts offer much more then only deployment related tasks. We also have tasks to make your local development easier. To get a list of all receipts type:

```shell
$ bundle exec cap -T alchemy
```

##### Import data from server

```shell
$ bundle exec cap alchemy:import:all
```

This imports your servers data onto your local development machine. This is very handy if you want to clone the current server state.

##### Export data to server

That even works the other way around:

```shell
$ bundle exec cap alchemy:export:all
```

**NOTE:** This will **overwrite the database** on your server. But calm down my dear friend, Alchemy will ask you to perform a backup before overwriting it.

#### Without Capistrano

If you don't use Capistrano you have to **make sure** that the `uploads`, `tmp/cache/assets`, `public/assets` and `public/pictures` folders get **shared between deployments**, otherwise you **will loose data**. No, not really, but you know, just keep them in sync.

Please take a look into Alchemys [Capistrano receipt](https://github.com/AlchemyCMS/alchemy_cms/blob/master/lib/alchemy/capistrano.rb) in order to see how you could achieve this.


Testing
-------

If you want to contribute to Alchemy ([and we encourage you to do so](https://github.com/AlchemyCMS/alchemy_cms/blob/master/CONTRIBUTING.md)) we have a strong test suite that helps you to not break anything.

To prepare the tests of your Alchemy fork please make sure to run the preparation task:

```shell
# ~/your/local/alchemy_cms
$ bin/rake alchemy:spec:prepare
```

to set up the database for testing.

##### Run your tests with:

```shell
$ bundle exec rspec
```

**Alternatively** you can just run:

```shell
$ bundle exec rake
```

*) This default task executes the database preparations and runs all defined test cases.

**A note about RSpec version:**

Alchemy specs are written **in RSpec 3**. Please **do not use deprecated RSpec 2.x syntax**. Thanks


Getting Help
------------

* Read the guidelines: http://guides.alchemy-cms.com.
* Read the documentation: http://rubydoc.info/github/AlchemyCMS/alchemy_cms
* If you found a bug please use the [issue tracker on Github](https://github.com/AlchemyCMS/alchemy_cms/issues).
* For questions about general usage please use [Stack Overflow](http://stackoverflow.com/questions/tagged/alchemy-cms), [the User Group](http://groups.google.com/group/alchemy-cms) or the [IRC channel](irc://irc.freenode.net#alchemy_cms).
* New features should be discussed on our [Trello Board](https://trello.com/alchemycms).

**PLEASE** don't use the Github issues for feature requests. If you want to contribute to Alchemy please [read the contribution guidelines](https://github.com/AlchemyCMS/alchemy_cms/blob/master/CONTRIBUTING.md) before doing so.


Resources
---------

* Homepage: <http://alchemy-cms.com>
* Live-Demo: <http://demo.alchemy-cms.com> (user: demo, password: demo123)
* API Documentation: <http://rubydoc.info/github/AlchemyCMS/alchemy_cms>
* Issue-Tracker: <https://github.com/AlchemyCMS/alchemy_cms/issues>
* Sourcecode: <https://github.com/AlchemyCMS/alchemy_cms>
* User Group: <http://groups.google.com/group/alchemy-cms>
* IRC Channel: <irc://irc.freenode.net#alchemy_cms>
* Discussion Board: <https://trello.com/alchemycms>
* Twitter: <https://twitter.com/alchemy_cms>


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


Spread the love
---------------

If you like Alchemy, please help us to spread the word about Alchemy and star this repo [on GitHub](https://github.com/AlchemyCMS/alchemy_cms), upvote it [on The Ruby Toolbox](https://www.ruby-toolbox.com/projects/alchemy_cms), mention us [on Twitter](https://twitter.com/alchemy_cms) and vote for it [on Bitnami](https://bitnami.com/stack/alchemy).

That will help us to keep Alchemy awesome.

Thank you <3!
