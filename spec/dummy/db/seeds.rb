# frozen_string_literal: true

Alchemy::Seeder.seed!

# Development admin so you can log into the dummy app right away (admin/test1234).
if defined?(Alchemy::User)
  Alchemy::User.find_or_create_by!(login: "admin") do |user|
    user.email = "admin@example.com"
    user.password = "test1234"
    user.password_confirmation = "test1234"
    user.alchemy_roles = ["admin"]
  end
end
