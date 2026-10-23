## Devise based authentication for AlchemyCMS

[![Gem Version](https://badge.fury.io/rb/alchemy-devise.svg)](http://badge.fury.io/rb/alchemy-devise)

AlchemyCMS has no authentication in its core. So it is possible to bring your own authentication and use it to authorize users in AlchemyCMS. If you don't have your own authentication, you can use this gem.

Since Alchemy CMS 9.0, `alchemy-devise` is developed inside the [Alchemy CMS repository](https://github.com/AlchemyCMS/alchemy_cms/tree/main/devise)
and released together with `alchemy_cms` using the same version.
Older versions are maintained in the [`alchemy-devise` repository](https://github.com/AlchemyCMS/alchemy-devise).

## Install

Just put the gem into your projects `Gemfile`.

```ruby
# Gemfile
gem 'alchemy-devise'
```

and run `bundle install`.

Then run the installer:

```bash
$ bin/rails g alchemy:devise:install
```

## Upgrading

After updating the gem, please run the installer again.

```bash
$ bundle update alchemy-devise
$ bin/rails g alchemy:devise:install
```

## Devise modules

Default Devise modules included in `Alchemy::User` model

- `:database_authenticatable`
- `:trackable`
- `:validatable`
- `:timeoutable`
- `:recoverable`
- `:rememberable`

If you want to add additional modules into the Alchemy user class append them to `Alchemy::Devise.config.devise_modules` in an initializer in your app.

### Register additional modules example

```ruby
# config/initializers/alchemy.rb
Alchemy::Devise.config.devise_modules << :registerable
```

### Using old encryption

If your app uses an old encryption that needs the +devise-encryptable+ gem you also need to load the devise module.

```ruby
# config/initializers/alchemy.rb
Alchemy::Devise.config.devise_modules << :encryptable
```

## Role changes

Granting or revoking the `admin` role asks the admin performing the change to
confirm their own password, both when creating a user and when editing one.
Since `admin` is the only role that can manage users, every other role and
every other user attribute can be edited with a valid session alone.

Roles that need a password are configurable:

```ruby
# config/initializers/alchemy.rb
Alchemy::Devise.config.privileged_user_roles << "editor"
```

Set this to `false` to grant roles with a valid session alone:

```ruby
# config/initializers/alchemy.rb
Alchemy::Devise.config.require_password_for_role_change = false
```

## Testing

If you want to contribute (and you should ^_^), you need to run the tests locally on your machine.

The gem has its own bundle and dummy app, so run all commands from the `devise` directory of the Alchemy CMS repository.
The bundle uses `alchemy_cms` from the parent directory, so the tests always run against the Alchemy CMS code next to it.

### 1. Once to prepare the test suite:

```bash
$ cd devise
$ bundle install
$ RAILS_ENV=test bundle exec rake alchemy:spec:prepare
```

### 2. Run the tests with:

```bash
$ bundle exec rspec
```

Getting Help
------------

* If you have bugs, please use the [issue tracker on Github](https://github.com/AlchemyCMS/alchemy_cms/issues).
* For Q&A and general usage, please use the [Slack](https://slackin.alchemy-cms.com)

Resources
---------

* Homepage: <https://alchemy-cms.com>
* Live-Demo: <https://alchemy-demo.herokuapp.com> (user: demo, password: demo123)
* Issue-Tracker: <https://github.com/AlchemyCMS/alchemy_cms/issues>
* Sourcecode: <https://github.com/AlchemyCMS/alchemy_cms/tree/main/devise>
* Slack: <https://slackin.alchemy-cms.com>

License
-------

* BSD: [LICENSE](LICENSE)
