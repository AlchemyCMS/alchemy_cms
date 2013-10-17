module Alchemy
  module Upgrader::ThreePointZero
    private

    def removed_users_model
      notice = <<-NOTE
We removed the users model from Alchemy core!

You have to provide your own user model or
add the `alchemy-devise` gem to your Gemfile.

In order to provide your own user model,
you have to be sure to met the API requirements
mentioned in the dummy user model:

  app/models/alchemy/dummy_user.rb

NOTE
      todo notice
    end

  end
end
