require 'spec_helper'

describe "Translation integration" do
  context "in admin backend" do
    let(:dummy_user) { mock_model(Alchemy.user_class, alchemy_roles: %w(admin), language: 'de') }

    before { authorize_user(dummy_user) }

    it "should be possible to set the locale of the admin backend via params" do
      visit admin_dashboard_path(admin_locale: 'nl')
      expect(page).to have_content('Welkom')
    end

    it "should store the current locale in the session" do
      visit admin_dashboard_path(admin_locale: 'nl')
      visit admin_dashboard_path
      expect(page).to have_content('Welkom')
    end

    it "should be possible to change the current locale in the session" do
      visit admin_dashboard_path(admin_locale: 'de')
      expect(page).to have_content('Willkommen')
      visit admin_dashboard_path(admin_locale: 'en')
      expect(page).to have_content('Welcome')
    end

    context 'with unknown locale' do
      it "it uses the users default language" do
        visit admin_dashboard_path(admin_locale: 'ko')
        expect(page).to have_content('Willkommen')
      end
    end

    context "if no other parameter is given" do
      it "should use the current users language setting" do
        visit admin_dashboard_path
        expect(page).to have_content('Willkommen')
      end

      context "if user has no preferred locale" do
        let(:dummy_user) { mock_model(Alchemy.user_class, alchemy_roles: %w(admin), language: nil) }

        it "should use the browsers language setting" do
          page.driver.header 'ACCEPT-LANGUAGE', 'es-ES'
          visit admin_dashboard_path
          expect(page).to have_content('Bienvenido')
        end
      end

      context "if user language is an instance of a model" do
        let(:language) { create(:alchemy_language) }
        let(:dummy_user) { mock_model(Alchemy.user_class, alchemy_roles: %w(admin), language: language) }

        context "if language doesn't return a valid locale symbol" do
          it "should use the browsers language setting" do
            page.driver.header 'ACCEPT-LANGUAGE', 'es-ES'
            visit admin_dashboard_path
            expect(page).to have_content('Bienvenido')
          end
        end

        context "if language returns a valid locale symbol" do
          before { allow(language).to receive(:to_sym).and_return(:nl) }

          it "should use the locale of the user language" do
            visit admin_dashboard_path
            expect(page).to have_content('Welkom')
          end
        end
      end
    end
  end
end
