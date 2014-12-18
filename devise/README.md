## Devise based authentication for Alchemy 3.0

[![Build Status](https://secure.travis-ci.org/magiclabs/alchemy-devise.svg?branch=master)](http://travis-ci.org/magiclabs/alchemy-devise) [![Coverage Status](https://coveralls.io/repos/magiclabs/alchemy-devise/badge.png?branch=master)](https://coveralls.io/r/magiclabs/alchemy-devise?branch=master) [![Code Climate](https://codeclimate.com/github/magiclabs/alchemy-devise.svg)](https://codeclimate.com/github/magiclabs/alchemy-devise)

**CAUTION: This master branch is a development branch that can contain bugs. For productive environments you should use the [current Ruby gem version](https://rubygems.org/gems/alchemy-devise/versions/2.0.0), or the [latest stable branch (2.0-stable)](https://github.com/magiclabs/alchemy-devise/tree/2.0-stable).**

Alchemy 3.0 has dropped the authentication from its core. So now it is possibly to bring your own authentication and use it to authorize users in Alchemy.

In order to bring the authentication from Alchemy back into your app (For instance, because you don't have your own user authorization), you can use this gem.

## Install

Just put the gem into your projects `Gemfile`.

```ruby
# Gemfile
gem 'alchemy-devise', github: 'magiclabs/alchemy-devise', branch: 'master'
```

**NOTE:** You normally want to use a stable branch, like `2.0-stable`.

and run `bundle install`.

Migrate the database:

```shell
$ bin/rake alchemy_devise:install:migrations
$ bin/rake db:migrate
```

## Upgrading

After updating the gem, please also check if new migrations have been added.

```shell
$ bundle update alchemy-devise
$ bin/rake alchemy_devise:install:migrations
```

and if new migrations have been added then migrate your database:

```shell
$ bin/rake db:migrate
```

## Testing

If you want to contribute (and you should ^_^), you need to run the tests locally on your machine.

Just follow these pretty rails standard way of testing projects:

### 1. Once to prepare the test suite:

Clone the repo to your local harddrive. Then

```shell
$ bundle install
$ rake alchemy:spec:prepare
```

### 2. Run the tests with:

```shell
$ rspec
```

_Optional:_ Even shorter

```shell
$ rake
```

That prepares the database and runs the Rspec task in one step.

Getting Help
------------

* If you have bugs, please use the [issue tracker on Github](https://github.com/magiclabs/alchemy-devise/issues).
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

License
-------

* BSD: <https://github.com/magiclabs/alchemy-devise/LICENSE>
