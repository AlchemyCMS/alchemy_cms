module Alchemy
  module Upgrader::TwoPointNine

    private

    def alchemy_29_todos
      notice = <<-NOTE

Alchemy User Class Removed
--------------------------

We removed the user model from the Alchemy core!

You have to provide your own user model or
add the `alchemy-devise` gem to your Gemfile.

If you want to use the default user class from Alchemy:

  # Gemfile
  gem 'alchemy-devise', '~> 1.1'

  $ bin/rake alchemy_devise:install:migrations db:migrate

In order to add your own user class to Alchemy, please
make shure it meets the API:

https://github.com/magiclabs/alchemy_cms/blob/2.9-stable/lib/alchemy/auth_accessors.rb

NOTE
      todo notice
    end
  end
end
