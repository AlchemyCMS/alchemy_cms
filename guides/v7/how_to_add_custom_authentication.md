# Custom Authentication

Alchemy 3.0 has removed its build in authentication into a separate gem called [alchemy-devise](https://github.com/AlchemyCMS/alchemy-devise).

Now, that this is not in the core anymore it gives you the possibility to add your own custom authentification. You only have to tell Alchemy about your user class.

In this guide you will learn to:

* add just enough code to make your User class work with Alchemy
* add additionally methods to enhance the integration

## Activating your model

Alchemy has some defaults for user model name and login logout path names:

### Defaults

* `Alchemy.user_class_name` defaults to `'User'`
* `Alchemy.login_path` defaults to `'/login'`
* `Alchemy.logout_path` defaults to `'/logout'`

Anyway, you can tell Alchemy about your authentication model configuration.

### Example

~~~ ruby
# config/initializers/alchemy.rb
Alchemy.user_class_name = 'Admin'
Alchemy.login_path = '/auth/login'
Alchemy.logout_path = '/auth/logout'
~~~

## Mandatory configuration

### Relationships
- `has_many :folded_pages` -
  This will allow alchemy to store page tree folding on a per user basis.



### Setting roles

The only method that AlchemyCMS needs from your user class is `alchemy_roles`. This method has to return an array of strings containing at least one of these roles:

* `member`
* `author`
* `editor`
* `admin`

### Example

~~~ ruby
# app/models/user.rb

def alchemy_roles
  if admin?
    %w(admin)
  else
    []
  end
end
~~~

::: tip
You can use your own authorization system to set the role. You only need to ensure that it returns an Array with at least one of the roles.
:::

That's it. Alchemy has everything it needs to use your user class as authentication model.

## Optional methods

Although Alchemy does not need much to know about your user class, there are some few other attributes that are good to have in your user class which are:

### Name

This would be used to say "Welcome back `#{@user.name}`" in the Alchemy dashboard.

### Example

~~~ ruby
# app/models/user.rb

def name
  # If you don't have a name, you could use the user's email
  read_attribute(:email)
end
~~~

### Display name

This is used in the "logged in as" note on the top right corner of the admin interface.

### Example

~~~ ruby
# app/models/user.rb

def alchemy_display_name
  # If you don't have a name, you could use the user's email
  "#{firstname} #{lastname}".strip
end
~~~

## Preferred Language

A locale String to set the users preferred translation of the Alchemy GUI.
Anyway, the user has always the option to switch the language, but it is good
to give your user its preferred language.

### Example

~~~ ruby
# app/models/user.rb

def language
  # Always use dutch as translation
  'nl'
end
~~~

::: tip
In a real world application you maybe want to store this as `alchemy_language` in the users table.
:::

## User stamp columns

Alchemy stores updater and creator ids (if the columns are present).
If you want to track which user updated a record you need to add:

`creator_id` and `updater_id`

to your users table.

### Example

~~~ bash
bin/rails g migration add_creator_id_and_updater_id_to_users creator_id:integer:index updater_id:integer:index
bin/rake db:migrate
~~~

## Tagging

If you want your users to be taggable you need to add the `acts_as_taggable` and `acts_as_tagger` class methods.

### Example

~~~ ruby
class User < ActiveRecord::Base
  acts_as_taggable
  acts_as_tagger
  ...
end
~~~

::: tip
You also should add a `cached_tag_list` text column into your users table for better performance.
:::

~~~ bash
bin/rails g migration add_cached_tag_list_to_users cached_tag_list:text
~~~

This is it! Now your user class should be a first class citizen of the Alchemy admin backend.
