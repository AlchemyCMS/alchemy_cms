require 'spec_helper'

describe "Translation integration" do
  context "in admin backend" do
    before { authorize_as_admin(mock_model('DummyUser', alchemy_roles: %w(admin), language: 'de')) }

    it "should be possible to set the locale of the admin backend via params" do
      visit admin_dashboard_path(locale: 'de')
      page.should have_content('Willkommen')
    end

    it "should store the current locale in the session" do
      visit admin_dashboard_path(locale: 'de')
      visit admin_dashboard_path
      page.should have_content('Willkommen')
    end

    it "should be possible to change the current locale in the session" do
      visit admin_dashboard_path(locale: 'de')
      page.should have_content('Willkommen')
      visit admin_dashboard_path(locale: 'en')
      page.should have_content('Welcome')
    end

    context 'with unknown locale' do
      it "it uses the users default language" do
        visit admin_dashboard_path(locale: 'ko')
        page.should have_content('Willkommen')
      end
    end

    context "if no other parameter is given" do
      it "should use the current users language setting" do
        visit admin_dashboard_path
        page.should have_content('Willkommen')
      end
    end

    context "with translated header" do
      before { Capybara.current_driver = :rack_test_translated_header }

      it "should use the browsers language setting if no other parameter is given" do
        visit admin_dashboard_path
        page.should have_content('Willkommen')
      end
    end
  end
end
