# Upgrading AlchemyCMS

This guide describes how to upgrade AlchemyCMS to version 3.0.0 and assumes that your current Alchemy version is v2.8.x.

* You should always upgrade from the next prior Alchemy release (based on your current version).
* This AlchemyCMS upgrade calls for upgrading Rails from v3.2 to v4.0.

Depending on your App, upgrading Rails to v4.0 might be a bigger challenge. This guide covers the basics for upgrading Alchemy driven Rails apps without any individual routes, controllers and models.

There is a very good [screencast by Ryan Bates that covers the Rails upgrade](http://railscasts.com/episodes/415-upgrading-to-rails-4) a bit more detailled. Thank you, Ryan!

Railsdiff shows diffs of Rails versions. There you can look up what exactly changed. [Diff of v3.2 and v4.0](http://railsdiff.org/3.2.22.5/4.0.13).

## Update the dependencies

In order to update the dependencies, the `Gemfile` needs to be changed first.

* The grouping for the asset related gems is not necessary anymore. That means all the gems in the `assets` group can be moved to the global area now.
* Versions of `rails`, `sass-rails`, `coffee-rails` and `uglifier` needs to be raised.
* The complete authentication part is extracted from the Alchemy core, so the `alchemy-devise` gem is necessary now.

That part of your updated Gemfile should look like this:

~~~ ruby
...
gem 'rails', '~> 4.0.2'
gem 'sass-rails', '~> 4.0.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'

gem 'alchemy_cms',    github: 'AlchemyCMS/alchemy_cms',    branch: '3.0-stable'
gem 'alchemy-devise', github: 'AlchemyCMS/alchemy-devise', branch: '2.0-stable'
...
~~~

You should now update the dependencies via bundler.

~~~ bash
bundle update
~~~

## Rails 4 Update

~~~ bash
bin/rake rails:update
~~~

This task guides you through all changes and asks what you want to do.

::: warning NOTE
You should not change `config/routes.rb` by the task. Also your locale yml files in `config/locales/` should not be overwritten if you have individual content in there.
:::

The other files can mostly be used as suggested by the update task.

But please *always double* check that you dont overwrite your individual adjustments in any of the files.

### Secret token handling

In `config/initializers/secret_token.rb` the secret token of your application is stored.

With Rails 4 the `secret_token` is now `secret_key_base`. It now encrypts all the contents of cookie based sessions.

Both configurations can exists together, so the `secret_key_base` can detach the secret_token gradually.
Depending on your App, you can also remove the `secret_token` immediately if the existing cookies of your users are unimportant.

More information here: [http://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#action-pack](http://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#action-pack)

~~~ ruby
Myapp::Application.config.secret_token = 'existing secret token'
Myapp::Application.config.secret_key_base = 'new secret key base'
~~~

## Installing alchemy-devise migrations

In order to update the user model, the migrations of the `alchemy-devise` gem need to be copied to the App.

~~~ bash
bin/rake alchemy_devise:install:migrations
~~~

## Run the Alchemy Upgrader

Now you can run the upgrade task.
While upgrading, you will get informations about the process on your screen.

~~~ bash
bin/rake alchemy:upgrade
~~~

## Changes for the Alchemy configuration file

The Upgrade task added an up-to-date `config.yml.defaults` to the `config/alchemy` folder.

Alchemy v3.0 comes with some config changes that need to be slipped in to the `config/alchemy/config.yml` file.

### Remove the Devise module configuration

~~~ yaml
# === Devise modules
#
# List of Devise modules that should be activated on the user model.
#
devise_modules:
  - :database_authenticatable
  - :trackable
  - :validatable
  - :timeoutable
  - :recoverable
  # - :encryptable # Uncomment this if you are upgrading from an Alchemy version < 2.5.0
~~~

### Adjust the user roles

The old role `registered` is now `member`

~~~ yaml
user_roles: [member, author, editor, admin]
~~~

### Add the regular expression for verifying email addresses and urls

~~~ yaml
format_matchers:
  email: !ruby/regexp '/\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/'
  url: !ruby/regexp '/\A[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/ix'
  link_url: !ruby/regexp '/^(mailto:|\/|[a-z]+:\/\/)/'
~~~

## Changes in Alchemy you should know about

Some parts in Alchemy have changed. You might need to update your code, so please have a look at the following points.

### Ferret has been extracted

If you are using the ferret search feature with your Alchemy driven application, you now need to require it as a gem in your `Gemfile`.

~~~ ruby
gem 'alchemy-ferret', github: 'AlchemyCMS/alchemy-ferret'
~~~

### TinyMCE 4 Upgrade

The TinyMCE configuration syntax has changed.

If you have custom TinyMCE confugurations, like a customized toolbar then you have to upgrade the syntax to a TinyMCE 4 compatible one.
Please have a look in the default TinyMCE configuration from Alchemy and also read the official TinyMCE documentation in how to upgrade.

* [Alchemy default TinyMCE config](https://github.com/AlchemyCMS/alchemy_cms/blob/master/lib/alchemy/tinymce.rb#8-L26)
* [Offical TinyMCE documentation](http://www.tinymce.com/wiki.php/Configuration)

### Rendering Alchemy's menubar

The way of rendering Alchemy's menubar has changed (on your application layout). Please replace the old helper call `alchemy_menu_bar` with: `render 'alchemy/menubar'`.

## Fix your capistrano deployment setup

Alchemy's build in Capistrano tasks are compatible with Capistrano 2.0 only at the moment.

Please update your `Gemfile`

~~~ ruby
gem 'capistrano', '~> 2.15.5'
~~~

If you use the capistrano tasks from Alchemy, you need to run `bundle exec cap deploy:setup` to create `cache/assets` in your shared folder, because Alchemy 3.0 now symlinks `cache/assets` from the current release to the shared folder.
