require "rails_helper"

RSpec.describe "Alchemy::Devise locales" do
  let(:locales) do
    Dir[Alchemy::Devise::Engine.root.join("config", "locales", "*.yml")]
      .map { File.basename(_1, ".yml") }
      .reject { _1.start_with?("devise.") }
  end

  it "ships more than the default locale" do
    expect(locales).to include("en", "de")
  end

  it "interpolates the role confirmation in every shipped locale", :aggregate_failures do
    expect(locales).to_not be_empty

    locales.each do |locale|
      create_message = I18n.t("alchemy.admin.users.confirm_password_for_role_change.create",
        locale: locale, roles: "Administrator", user: "Jane Doe", raise: true)
      update_message = I18n.t("alchemy.admin.users.confirm_password_for_role_change.update",
        locale: locale, roles: "Administrator", user: "Jane Doe", raise: true)

      expect(create_message).to include("Administrator"), "#{locale} create drops the role"
      expect(update_message).to include("Administrator"), "#{locale} update drops the role"
      expect(update_message).to include("Jane Doe"), "#{locale} update drops the user"
    end
  end
end
