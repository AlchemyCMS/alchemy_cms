---
prev: false
next: /about.html
---

# Getting Started

This guide covers getting up and running with AlchemyCMS. After reading it, you should be familiar with:

* Installing and creating a new application with AlchemyCMS
* Creating a user and logging in for the first time.

## Prerequisites

This guide is designed for beginners who want to get started with AlchemyCMS from scratch. It does not assume that you have any prior experience with AlchemyCMS. However, to get the most out of it, you need to have some prerequisites installed:

* The [Ruby](http://www.ruby-lang.org/en/downloads) programming language
* At least one of these databases: [MySQL](http://www.mysql.com/downloads/mysql) or [PostgreSQL](http://www.postgresql.org/download)
* The image processing library [ImageMagick](http://www.imagemagick.org/script/install-source.php)

### Installing dependencies

**It is highly recommended** to use a package manager to install dependencies like ImageMagick and your database.

Common package managers are:

* [Homebrew](http://brew.sh) on the Mac
* Your Linux box already has a package manager installed and you likely are already familiar with it.

### Installing Ruby

The most common ways to install Ruby on your computer nowadays are:

* If you are on a Mac or Linux Box use [RVM](http://rvm.io)
* If you are on Windows use [RailsInstaller](http://railsinstaller.org)

### Learning Rails

It is highly recommended to familiarize yourself with Ruby on Rails before using AlchemyCMS.
You will understand much more and see things clearer if you know about the basics of Ruby on Rails.

There are many excellent resources on the internet for learning Ruby on Rails, including:

* [Try Ruby](http://tryruby.org)
* [Getting Started with Rails](http://guides.rubyonrails.org/getting_started.html)
* [Rails for Zombies](http://railsforzombies.org)
* [Railscasts](http://railscasts.com)

## Installing Alchemy

### Create the Rails application

The installation of AlchemyCMS is very easy. You just need to run Ruby's `gem` command.

~~~ bash
gem install alchemy_cms
~~~

Alchemy is a Rails 4 engine, so at first you need to generate a fresh Rails 4 application, by running this command

~~~ bash
rails new YOUR_APP_NAME
~~~

::: tip INFO
The `rails` command has lots of parameters like choosing the database you want to work with. Please follow [the official Rails guides](https://guides.rubyonrails.org/getting_started.html) for further information.
:::

### Install Alchemy into the Rails application

In your existing Rails application, you can need to require the AlchemyCMS gem.

Just add this line to your `Gemfile`.

~~~ ruby
gem 'alchemy_cms'
~~~

Since AlchemyCMS is a mountable engine, you need to define the mountpoint in your `config/routes.rb` file.

~~~ ruby
MyApp::Application.routes.draw do
  mount Alchemy::Engine => '/'
end
~~~

::: tip
You can mount Alchemy on every route you want. `pages`, `cms`, what ever you want. Most of the time you go with the root route.
:::

::: warning NOTE
Please be aware that Alchemy has a very strong catch all route. It is *highly recommended* that you mount Alchemy at last position in your app, so your existing routes are still available.
:::

Now you need to run bundler for installing the dependencies.

~~~ bash
bundle install
~~~

Then run the install task.

~~~ bash
bin/rake alchemy:install
~~~

#### Authentication

If you already have your own user class in your application, you have to tell Alchemy about it. Please follow [this guide](custom_authentication.html) to learn how to achieve that.

If you don't have a authentication solution, you can use the alchemy-devise gem.

Just add it to your apps `Gemfile`

~~~ ruby
# Gemfile
gem 'alchemy-devise'
~~~

~~~ bash
bundle install
~~~

and run the installer

~~~ bash
bin/rails alchemy:devise:install
~~~

## Starting AlchemyCMS

Now that you have AlchemyCMS successfully installed, let's move on by creating your first user with administrative privilegs.

You just need to start a local ruby server on your development machine.

~~~ bash
cd YOUR_APP_NAME
~~~

~~~ bash
bin/rails s
~~~

Open a browser window and navigate to [http://localhost:3000](http://localhost:3000).
You will be greeted with a screen that is prompting you to create the first user.

Congratulations, you can now access the backend.
