module Alchemy
  module Upgrader::ThreePointZero
    private

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

    def alchemy_3_todos
      notice = <<-NOTE

Alchemy User Class Removed
--------------------------

We removed the users model from Alchemy core!

You have to provide your own user model or
add the `alchemy-devise` gem to your Gemfile.

If you want to use the default user class from Alchemy:

  # Gemfile
  gem 'alchemy-devise'

  $ bin/rake alchemy_devise:install:migrations db:migrate

In order to add your own user class to Alchemy, please
make shure it meets the API:

https://github.com/magiclabs/alchemy_cms/blob/master/lib/alchemy/auth_accessors.rb


TinyMCE 4 Upgrade
-----------------

The TinyMCE configuration syntax has changed!

If you have custom TinyMCE confugurations, like a customized toolbar
then you have to upgrade the syntax to a TinyMCE 4 compatible one.

Please have a look in the default TinyMCE configuration from Alchemy and
also read the official TinyMCE documentation in how to upgrade.

Alchemy default TinyMCE config: https://github.com/magiclabs/alchemy_cms/blob/master/lib/alchemy/tinymce.rb#L5-L19
Offical TinyMCE documentation: http://www.tinymce.com/wiki.php/Configuration

NOTE
      todo notice, 'Alchemy v3.0 changes'
    end

  end
end
