# AlchemyCMS

[![Gem Version](https://badge.fury.io/rb/alchemy_cms.svg)](http://badge.fury.io/rb/alchemy_cms)
[![Build Status](https://github.com/AlchemyCMS/alchemy_cms/workflows/CI/badge.svg?branch=main)](https://github.com/AlchemyCMS/alchemy_cms/actions)
[![Maintainability](https://api.codeclimate.com/v1/badges/196c56c56568ed24a697/maintainability)](https://codeclimate.com/github/AlchemyCMS/alchemy_cms/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/196c56c56568ed24a697/test_coverage)](https://codeclimate.com/github/AlchemyCMS/alchemy_cms/test_coverage)
[![Depfu](https://badges.depfu.com/badges/ebe56d2dd7b7044a8ae700cc81212a8e/overview.svg)](https://depfu.com/github/AlchemyCMS/alchemy_cms?project_id=4600)

[![Slack Status](https://slackin.alchemy-cms.com/badge.svg)](https://slackin.alchemy-cms.com)
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)

[![Backers on Open Collective](https://opencollective.com/alchemy_cms/backers/badge.svg?color=blue)](#backers)
[![Sponsors on Open Collective](https://opencollective.com/alchemy_cms/sponsors/badge.svg?color=blue)](#sponsors)

<img src="./app/assets/images/alchemy/alchemy-logo.svg" width=300>

Alchemy is an open source CMS engine written in Ruby on Rails.

Read more about Alchemy on the [website](https://alchemy-cms.com) and in the [guidelines](https://guides.alchemy-cms.com).

**CAUTION: This main branch is a development branch that *can* contain bugs. For productive environments you should use the [current Ruby gem version](https://rubygems.org/gems/alchemy_cms), or the [latest stable branch (5.0-stable)](https://github.com/AlchemyCMS/alchemy_cms/tree/5.0-stable).**


## ✅ Features

- Flexible templating that separates content from markup
- A rich RESTful API
- Intuitive admin interface with live preview
- Multi language and multi domain
- SEO friendly urls
- User Access Control
- Build in contact form mailer
- Attachments and downloads
- On-the-fly image cropping and resizing
- Extendable via Rails engines
- Integrates into existing Rails Apps
- Resourceful Rails admin
- Flexible caching
- Hostable on any Server that supports Ruby on Rails, a SQL Database and ImageMagick

## 🎮 Demo

Deploy your own free demo on Heroku

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/AlchemyCMS/alchemy-demo)

or visit the existing demo at https://alchemy-demo.herokuapp.com

- Login: `demo`
- Password: `demo123`

## 🚂 Rails Version

**This version of AlchemyCMS runs with Rails 6.0**

* For a Rails 5.2 compatible version use the [`5.2-stable` branch](https://github.com/AlchemyCMS/alchemy_cms/tree/5.2-stable).
* For a Rails 5.0 or 5.1 compatible version use the [`4.5-stable` branch](https://github.com/AlchemyCMS/alchemy_cms/tree/4.5-stable).
* For a Rails 4.2 compatible version use the [`3.6-stable` branch](https://github.com/AlchemyCMS/alchemy_cms/tree/3.6-stable).
* For a Rails 4.0/4.1 compatible version use the [`3.1-stable` branch](https://github.com/AlchemyCMS/alchemy_cms/tree/3.1-stable).
* For a Rails 3.2 compatible version use the [`2.8-stable` branch](https://github.com/AlchemyCMS/alchemy_cms/tree/2.8-stable).
* For a Rails 3.1 compatible version use the [`2.1-stable` branch](https://github.com/AlchemyCMS/alchemy_cms/tree/2.1-stable).
* For a Rails 3.0 compatible version use the [`2.0-stable` branch](https://github.com/AlchemyCMS/alchemy_cms/tree/2.0-stable).
* For a Rails 2.3 compatible version use the [`1.6-stable` branch](https://github.com/AlchemyCMS/alchemy_cms/tree/1.6-stable).


## 💎 Ruby Version

Alchemy runs with Ruby >= 2.5.0.

For a Ruby 2.4 compatible version use the [`5.2-stable` branch](https://github.com/AlchemyCMS/alchemy_cms/tree/5.2-stable).

For a Ruby 2.2 compatible version use the [`4.1-stable` branch](https://github.com/AlchemyCMS/alchemy_cms/tree/4.1-stable).

For a Ruby 2.1 compatible version use the [`3.6-stable` branch](https://github.com/AlchemyCMS/alchemy_cms/tree/3.6-stable).

For a Ruby 2.0.0 compatible version use the [`3.2-stable` branch](https://github.com/AlchemyCMS/alchemy_cms/tree/3.2-stable).

For a Ruby 1.9.3 compatible version use the [`3.1-stable` branch](https://github.com/AlchemyCMS/alchemy_cms/tree/3.1-stable).

For a Ruby 1.8.7 compatible version use the [`2.3-stable` branch](https://github.com/AlchemyCMS/alchemy_cms/tree/2.3-stable).


## ⌨️ Installation

### Stand Alone Installation

If you do not have a Rails project yet or just want to check out Alchemy, then use this Rails template.

Make sure you have Rails installed first:

```
$ gem install rails
```

Then create a new Rails project with:

```
$ rails new -m https://raw.githubusercontent.com/AlchemyCMS/rails-templates/master/all.rb <MY-PROJECT-NAME>
```

and follow the on screen instructions.

### Manual Installation

If you want to manually install Alchemy into your Rails project follow these steps.

#### Add the Alchemy gem:

Put Alchemy into your `Gemfile` with:

```
$ bundle add alchemy_cms
```

#### Set the authentication user

Now you have to decide, if you want to use your own user model or if you want to use
the Devise based user model that Alchemy provides and was extracted [into its own gem](https://github.com/AlchemyCMS/alchemy-devise).

##### Use Alchemy user

If you don't have your own user class, you can use the Alchemy user model. Just add the following gem into your `Gemfile`:

```
$ bundle add alchemy-devise
```

Then run the `alchemy-devise` installer:

```bash
$ bin/rails g alchemy:devise:install
```

##### Use your User model

In order to use your own user model you need to tell Alchemy about it.

The best practice is to use an initializer:

```ruby
# config/initializers/alchemy.rb
Alchemy.user_class_name     = 'YourUserClass'          # Defaults to 'User'
Alchemy.current_user_method = 'current_admin_user'     # Defaults to 'current_user'
Alchemy.signup_path         = '/your/signup/path'      # Defaults to '/signup'
Alchemy.login_path          = '/your/login/path'       # Defaults to '/login'
Alchemy.logout_path         = '/your/logout/path'      # Defaults to '/logout'
Alchemy.logout_method       = 'http_verb_for_logout'   # Defaults to 'delete'
```

The only thing Alchemy needs to know from your user class is the `alchemy_roles` method.

This method has to return an `Array` (or `ActiveRecord::Relation`) with at least one of the following roles: `member`, `author`, `editor`, `admin`.

##### Example

```ruby
# app/models/user.rb

def alchemy_roles
  if admin?
    %w(admin)
  end
end
```

Please follow [this guide](http://guides.alchemy-cms.com/stable/custom_authentication.html) for further instructions on how to customize your user class even more.

#### 4. Install Alchemy into your app:

**After** you set the user model you need to run the Alchemy install task:

```bash
$ bin/rails alchemy:install
```

Now everything should be set up and you should be able to visit the Alchemy Dashboard at:

<http://localhost:3000/admin>

*) Use your custom path if you mounted Alchemy at something else then `'/'`


## 🏗 Customization

Alchemy has very flexible ways to organize and manage content. Please be sure to read [the introduction guide](https://guides.alchemy-cms.com/about.html) in order to understand the basic idea of how Alchemy works.


### Custom Controllers

Beginning with Alchemy 3.1 we do not patch the `ApplicationController` anymore. If you have controllers that loads Alchemy content or uses Alchemy helpers in the views (i.e. `render_menu` or `render_elements`) you can either inherit from `Alchemy::BaseController` or you `include Alchemy::ControllerActions` in your controller (**that's the recommended way**).

### Custom admin interface routing

By default, Alchemy Dashboard is accessible at <http://example.com/admin>. You can change this by setting `Alchemy.admin_path` and `Alchemy.admin_constraints`.

For example, these settings:

```ruby
# config/initializers/alchemy.rb

Alchemy.admin_path = 'backend'
Alchemy.admin_constraints = {subdomain: 'hidden'}
```

will move the dashboard to <http://hidden.example.com/backend>.

### Picture caching

Alchemy uses the Dragonfly gem to render pictures on-the-fly.

To make this as performant as possible the rendered picture gets stored into `public/pictures` so the web server can pick up the file and serve it without hitting the Rails process at all.

This may or may not what you want. Especially for multi server setups you eventually want to use something like S3.

Please follow the guidelines about picture caching on the Dragonfly homepage for further instructions:

http://markevans.github.io/dragonfly/cache

We also provide an [extension for Cloudinary](https://github.com/AlchemyCMS/alchemy_cloudinary)

## 🌍 Localization

Alchemy ships with one default English translation for the admin interface. If you want to use the admin interface in other languages please have a look at the [`alchemy_i18n` project](https://github.com/AlchemyCMS/alchemy_i18n).

## ✨ Upgrading

We, the Alchemy team, take upgrades very seriously and we try to make them as smooth as possible. Therefore we have build an upgrade task, that tries to automate the upgrade procedure as much as possible.

That's why after the Alchemy gem has been updated, with explicit call to:

```bash
$ bundle update alchemy_cms
```

you should **always run the upgrader**:

```bash
$ bin/rake alchemy:upgrade
```

Alchemy will print out useful information after running the automated tasks that help a smooth upgrade path.
So please **take your time and read them**.

Always be sure to keep an eye on the `config/alchemy/config.yml.defaults` file and update your `config/alchemy/config.yml` accordingly.

Also, `git diff` is your friend.

### Customize the upgrade preparation

The Alchemy upgrader comes prepared with several rake tasks in a specific order.
This is sometimes not what you want or could even break upgrades.
In order to customize the upgrade preparation process you can instead run each of the tasks on their own.

```bash
$ bin/rake alchemy:install:migrations
$ bin/rake db:migrate
$ bin/rake alchemy:db:seed
$ bin/rake alchemy:upgrade:config
$ bin/rake alchemy:upgrade:run
```

**WARNING:** This is only recommended, if you have problems with the default `rake alchemy:upgrade` task and need to
repair your data in between. The upgrader depends on these upgrade tasks running in this specific order, otherwise
we can't ensure smooth upgrades for you.

### Run an individual upgrade

You can also run an individual upgrade on its own:

```bash
$ bin/rake -T alchemy:upgrade
```

provides you with a list of each upgrade you can run individually.

#### Example

```bash
$ bin/rake alchemy:upgrade:4.1
```

runs only the Alchemy 4.1 upgrade

## 🚀 Deployment

Alchemy has an official Capistrano extension which takes care of everything you need to deploy an Alchemy site.

Please use [capistrano-alchemy](https://github.com/AlchemyCMS/capistrano-alchemy), if you want to deploy with Capistrano.

### Without Capistrano

If you don't use Capistrano you have to **make sure** that the `uploads`, `tmp/cache/assets`, `public/assets` and `public/pictures` folders get **shared between deployments**, otherwise you **will loose data**. No, not really, but you know, just keep them in sync.


## 🚧 Testing

If you want to contribute to Alchemy ([and we encourage you to do so](CONTRIBUTING.md)) we have a strong test suite that helps you to not break anything.

### Preparation

First of all you need to clone your fork to your local development machine. Then you need to install the dependencies with bundler.

```bash
$ bundle install
```

To prepare the tests of your Alchemy fork please make sure to run the preparation task:

```bash
$ bundle exec rake alchemy:spec:prepare
```

to set up the database for testing.

### Run your tests with:

```bash
$ bundle exec rspec
```

**Alternatively** you can just run*:

```bash
$ bundle exec rake
```

*) This default task executes the database preparations and runs all defined test cases.

### Start the dummy app

You can even start the dummy app and use it to manually test your changes with:

```bash
$ cd spec/dummy
$ bin/setup
$ bin/rails s
```


## 📦 Releasing

### Update the changelog

```bash
$ export GITHUB_ACCESS_TOKEN=...
$ PREVIOUS_VERSION=4.1.0 bundle exec rake alchemy:changelog:update
```

### Release a new version

```bash
$ bundle exec rake release
```


## ❓Getting Help

* Read the guidelines: https://guides.alchemy-cms.com.
* Read the documentation: https://www.rubydoc.info/github/AlchemyCMS/alchemy_cms
* If you think you found a bug please use the [issue tracker on Github](https://github.com/AlchemyCMS/alchemy_cms/issues).
* For questions about general usage please use [Stack Overflow](http://stackoverflow.com/questions/tagged/alchemy-cms) or the [Slack](https://slackin.alchemy-cms.com).
* New features should be discussed on our [Trello Board](https://trello.com/alchemycms).

**PLEASE** don't use the Github issues for feature requests. If you want to contribute to Alchemy please [read the contribution guidelines](CONTRIBUTING.md) before doing so.


## 🔗 Resources

* Homepage: <https://alchemy-cms.com>
* Live-Demo: <https://demo.alchemy-cms.com> (user: demo, password: demo123)
* API Documentation: <https://www.rubydoc.info/github/AlchemyCMS/alchemy_cms>
* Issue-Tracker: <https://github.com/AlchemyCMS/alchemy_cms/issues>
* Sourcecode: <https://github.com/AlchemyCMS/alchemy_cms>
* Slack: <https://slackin.alchemy-cms.com>
* Twitter: <https://twitter.com/alchemy_cms>


## ✍️ Authors

* Thomas von Deyen: <https://github.com/tvdeyen>
* Robin Böning: <https://github.com/robinboening>
* Marc Schettke: <https://github.com/masche842>
* Hendrik Mans: <https://github.com/hmans>
* Carsten Fregin: <https://github.com/cfregin>


## 🏅 Contributors

This project exists thanks to all the people who contribute. [[Contribute](CONTRIBUTING.md)].
<a href="https://github.com/undefined/undefinedgraphs/contributors"><img src="https://opencollective.com/alchemy_cms/contributors.svg?width=890&button=false" /></a>


## 💵 Backers

Thank you to all our backers! 🙏 [[Become a backer](https://opencollective.com/alchemy_cms#backer)]

<a href="https://opencollective.com/alchemy_cms#backers" target="_blank"><img src="https://opencollective.com/alchemy_cms/backers.svg?width=890"></a>


## 💰 Sponsors

Support this project by becoming a sponsor. Your logo will show up here with a link to your website. [[Become a sponsor](https://opencollective.com/alchemy_cms#sponsor)]

<a href="https://opencollective.com/alchemy_cms/sponsor/0/website" target="_blank"><img src="https://opencollective.com/alchemy_cms/sponsor/0/avatar.svg"></a>
<a href="https://opencollective.com/alchemy_cms/sponsor/1/website" target="_blank"><img src="https://opencollective.com/alchemy_cms/sponsor/1/avatar.svg"></a>
<a href="https://opencollective.com/alchemy_cms/sponsor/2/website" target="_blank"><img src="https://opencollective.com/alchemy_cms/sponsor/2/avatar.svg"></a>
<a href="https://opencollective.com/alchemy_cms/sponsor/3/website" target="_blank"><img src="https://opencollective.com/alchemy_cms/sponsor/3/avatar.svg"></a>
<a href="https://opencollective.com/alchemy_cms/sponsor/4/website" target="_blank"><img src="https://opencollective.com/alchemy_cms/sponsor/4/avatar.svg"></a>
<a href="https://opencollective.com/alchemy_cms/sponsor/5/website" target="_blank"><img src="https://opencollective.com/alchemy_cms/sponsor/5/avatar.svg"></a>
<a href="https://opencollective.com/alchemy_cms/sponsor/6/website" target="_blank"><img src="https://opencollective.com/alchemy_cms/sponsor/6/avatar.svg"></a>
<a href="https://opencollective.com/alchemy_cms/sponsor/7/website" target="_blank"><img src="https://opencollective.com/alchemy_cms/sponsor/7/avatar.svg"></a>
<a href="https://opencollective.com/alchemy_cms/sponsor/8/website" target="_blank"><img src="https://opencollective.com/alchemy_cms/sponsor/8/avatar.svg"></a>
<a href="https://opencollective.com/alchemy_cms/sponsor/9/website" target="_blank"><img src="https://opencollective.com/alchemy_cms/sponsor/9/avatar.svg"></a>



## 📜 License

[BSD-3-Clause](LICENSE)


## 📢 Spread the love

If you like Alchemy, please help us to spread the word about Alchemy and star this repo [on GitHub](https://github.com/AlchemyCMS/alchemy_cms), upvote it [on The Ruby Toolbox](https://www.ruby-toolbox.com/projects/alchemy_cms), mention us [on Twitter](https://twitter.com/alchemy_cms).

That will help us to keep Alchemy awesome.

Thank you!

## ❤️
