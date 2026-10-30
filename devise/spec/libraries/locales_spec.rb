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

  it "translates and interpolates user impersonation in every shipped locale", :aggregate_failures do
    locales.each do |locale|
      impersonate = I18n.t("alchemy.impersonate_user", locale: locale, fallback: false, raise: true)
      confirmation = I18n.t("alchemy.confirm_impersonate_user",
        locale: locale, user: "Jane Doe", fallback: false, raise: true)
      notice = I18n.t("alchemy.devise.user_impersonation.notice",
        locale: locale, user: "Jane Doe", fallback: false, raise: true)
      stop = I18n.t("alchemy.devise.user_impersonation.stop", locale: locale, fallback: false, raise: true)
      stop_confirmation = I18n.t("alchemy.devise.user_impersonation.stop_confirmation",
        locale: locale, fallback: false, raise: true)

      expect(impersonate).to be_present, "#{locale} has no impersonate action"
      expect(confirmation).to include("Jane Doe"), "#{locale} confirmation drops the user"
      expect(notice).to include("Jane Doe"), "#{locale} notice drops the user"
      expect(stop).to be_present, "#{locale} has no stop action"
      expect(stop_confirmation).to be_present, "#{locale} has no stop confirmation"
    end
  end
end
