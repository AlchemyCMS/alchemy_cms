# Custom Authentication

Alchemy does not ship with its own authentication. The [alchemy-devise](extensions#alchemy-devise) gem provides a ready-made solution using Devise, but you can use any authentication system.

You only need to tell Alchemy about your user class and implement a few methods. This guide covers configuration, the required `alchemy_roles` method, and recommended methods for a full integration.

## Configuration

Tell Alchemy about your user class and authentication paths in an initializer.

### Available Options

| Option | Default | Description |
|--------|---------|-------------|
| `user_class` | `"User"` | Your user model class name |
| `login_path` | `"/login"` | Path to the login form |
| `logout_path` | `"/logout"` | Path to the logout action |
| `logout_method` | `"delete"` | HTTP verb for the logout action |
| `signup_path` | `"/signup"` | Path to the signup form |
| `current_user_method` | `:current_user` | Controller method that returns the current user |
| `user_class_primary_key` | `:id` | Primary key column of your user model (useful for UUIDs) |

### Alchemy 8.1+ <Badge type="tip" text="8.1+" />

~~~ ruby
# config/initializers/alchemy.rb
Alchemy.configure do |config|
  config.user_class = "Admin"
  config.login_path = "/auth/login"
  config.logout_path = "/auth/logout"
  config.logout_method = "delete"
end
~~~

### Alchemy 8.0 <Badge type="warning" text="8.0" />

~~~ ruby
# config/initializers/alchemy.rb
Alchemy.user_class_name = "Admin"
Alchemy.login_path = "/auth/login"
Alchemy.logout_path = "/auth/logout"
~~~

:::warning
This syntax is deprecated since Alchemy 8.1 and will be removed in a future version.
:::

## Required

The only method Alchemy needs from your user class is `alchemy_roles`. It must return an array of strings containing at least one of these roles:

* `member`
* `author`
* `editor`
* `admin`

~~~ ruby
# app/models/user.rb
def alchemy_roles
  if admin?
    %w(admin)
  else
    %w(member)
  end
end
~~~

:::tip
You can use your own authorization system to determine the role. Alchemy only needs an array with at least one of the roles listed above.
:::

## Recommended

These methods and associations are not strictly required, but without them parts of the admin interface will show missing or placeholder information.

### `name`

Used on the dashboard to greet the user ("Welcome back, [name]") and in the online users list. Without it, the greeting will be blank.

~~~ ruby
def name
  read_attribute(:email)
end
~~~

### `alchemy_display_name`

Shown in the "logged in as" area at the top right of the admin interface, and used for creator/updater/locker names on pages. Without it, these will show "unknown".

~~~ ruby
def alchemy_display_name
  "#{firstname} #{lastname}".strip
end
~~~

### `language`

A locale string for the user's preferred translation of the Alchemy admin interface. The user can always switch the language manually, but this sets the default.

~~~ ruby
def language
  "nl"
end
~~~

:::tip
In a real application you would store this as a column in the users table.
:::

### `admins`

Class method that returns a collection of admin users. Used to check if any admins exist (e.g. for signup eligibility).

~~~ ruby
def self.admins
  where(admin: true)
end
~~~

### Page Tree Folding

Alchemy remembers which pages a user has folded or expanded in the admin page tree. To enable this, add the following association:

~~~ ruby
has_many :folded_pages, class_name: "Alchemy::FoldedPage"
~~~

Without this, the page tree will work but folding state won't be persisted per user.

### Change Tracking

Alchemy stores `creator_id` and `updater_id` on records like pages, elements, and pictures. To track which user created or updated these records, add these columns to your users table:

~~~ bash
bin/rails g migration AddCreatorIdAndUpdaterIdToUsers creator_id:integer:index updater_id:integer:index
bin/rails db:migrate
~~~

## Optional

### Tagging

If you want your users to be taggable, include the `Alchemy::Taggable` module:

~~~ ruby
class User < ApplicationRecord
  include Alchemy::Taggable
end
~~~

This adds [Gutentag](https://github.com/pat/gutentag)-based tagging with the following methods:

* `tag_names` / `tag_list` -- get or set tags
* `tag_list=` -- set tags from a comma-separated string or array
* `User.tagged_with(["tag1", "tag2"])` -- find tagged records
* `User.tag_counts` -- list all unique tags

## Complete Example

~~~ ruby
class User < ApplicationRecord
  include Alchemy::Taggable

  has_many :folded_pages, class_name: "Alchemy::FoldedPage"

  def alchemy_roles
    if admin?
      %w(admin)
    else
      %w(member)
    end
  end

  def name
    email
  end

  alias_method :alchemy_display_name, :name

  def self.admins
    where(admin: true)
  end
end
~~~
