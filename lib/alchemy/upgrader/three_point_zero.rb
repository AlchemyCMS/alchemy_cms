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
mentioned in:

  lib/alchemy/auth_accessors.rb

NOTE
      todo notice
    end

    def rename_registered_role_ro_member
      desc 'Rename the `registered` user role to `member`'
      registered_users = Alchemy.user_class.where("alchemy_roles LIKE '%registered%'")
      if registered_users.any?
        registered_users.each do |user|
          roles = user.read_attribute(:alchemy_roles).sub(/registered/, 'member')
          user.update_column(:alchemy_roles, roles)
          log "Renamed #{user.inspect} role to `member`"
        end
      else
        log 'No users with `registered` role found.', :skip
      end
    end

  end
end
