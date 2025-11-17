# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard feature", type: :system do
  let(:user) { create(:alchemy_dummy_user, :as_editor, name: "Joe Editor") }

  before do
    authorize_user(user)
  end

  describe "Locked pages summary" do
    let(:a_page) { create(:alchemy_page, :public) }

    it "should not display when no pages are locked" do
      visit admin_dashboard_path
      expect(page).not_to have_css('.dashboard-locked-pages')
    end

    context "When locked by current user" do
      it "should show locked by me" do
        a_page.lock_to!(user)
        visit admin_dashboard_path
        locked_pages_widget = find('.dashboard-locked-pages')
        expect(locked_pages_widget).to have_content "Currently locked pages"
        expect(locked_pages_widget).to have_content a_page.name
        expect(locked_pages_widget).to have_content "Me"
        expect(locked_pages_widget).to have_css %(button[title="#{Alchemy.t(:explain_unlocking)}"])
        expect(locked_pages_widget).to have_css %(form[action="/admin/pages/#{a_page.id}/unlock?redirect_to=%2Fadmin%2Fdashboard"])
      end
    end

    context "When locked by another user" do
      let(:other_user) { create(:alchemy_dummy_user, :as_admin) }

      it "shows the name of the user who locked the page" do
        a_page.lock_to!(other_user)
        visit admin_dashboard_path
        locked_pages_widget = find('.dashboard-locked-pages')
        expect(locked_pages_widget).to have_content "Currently locked pages"
        expect(locked_pages_widget).to have_content a_page.name
        expect(locked_pages_widget).to have_content other_user.name
        expect(locked_pages_widget).not_to have_css "button[title=\"#{Alchemy.t(:explain_unlocking)}\"]"
      end
    end

    context "when logged in as admin" do
      let(:user) { create(:alchemy_dummy_user, :as_admin, name: "Joe Editor") }
      let(:other_user) { create(:alchemy_dummy_user, :as_admin) }

      it "shows the name of the user who locked the page" do
        a_page.lock_to!(other_user)
        visit admin_dashboard_path
        locked_pages_widget = find('.dashboard-locked-pages')
        expect(locked_pages_widget).to have_content "Currently locked pages"
        expect(locked_pages_widget).to have_content a_page.name
        expect(locked_pages_widget).to have_content other_user.name
        expect(locked_pages_widget).to have_css "button[title=\"#{Alchemy.t(:explain_unlocking)}\"]"
      end
    end
  end

  describe "Sites widget" do
    context "with multiple sites" do
      let!(:default_site) { create(:alchemy_site, :default) }
      let!(:another_site) { create(:alchemy_site, name: "Site", host: "site.com") }

      it "lists all sites" do
        visit admin_dashboard_path
        sites_widget = find('.dashboard-sites')
        expect(sites_widget).to have_content "Websites"
        expect(sites_widget).to have_content "Default Site"
        expect(sites_widget).to have_content "Site"
      end

      context "with alchemy url proxy object having `login_url`" do
        before do
          allow_any_instance_of(ActionDispatch::Routing::RoutesProxy).to receive(:login_url).and_return("http://site.com/admin/login")
        end

        it "links to login page of every site" do
          visit admin_dashboard_path
          sites_widget = find('.dashboard-sites')
          expect(sites_widget).to have_selector 'a[href="http://site.com/admin/login"]'
        end
      end
    end

    context "with only one site" do
      it "does not display" do
        visit admin_dashboard_path
        sites_widget = all('.dashboard-sites').first
        expect(sites_widget).to be_nil
      end
    end
  end

  describe "Online users" do
    context "with alchemy users" do
      let(:other_user) { build_stubbed(:alchemy_dummy_user) }

      before do
        expect(Alchemy.config.user_class).to receive(:logged_in) { [other_user] }
      end

      it "lists all online users besides current user" do
        visit admin_dashboard_path
        users_widget = find('.dashboard-online-users')
        expect(users_widget).to have_content other_user.name
        expect(users_widget).to have_content "Member"
        expect(users_widget).not_to have_content user.name
      end
    end

    context "with non alchemy user class" do
      before do
        stub_alchemy_config(user_class: "SomeUser")
      end

      it "does not list online users" do
        visit admin_dashboard_path
        users_widget = all('.dashboard-online-users').first
        expect(users_widget).to be_nil
      end
    end
  end

  describe "System info widget" do
    it "displays system information" do
      visit admin_dashboard_path
      system_info_widget = find('.dashboard-system-info')
      expect(system_info_widget).to have_content "System Info"
      expect(system_info_widget).to have_content "Alchemy Version"
      expect(system_info_widget).to have_content "Ruby Version"
      expect(system_info_widget).to have_content "Rails Version"
    end
  end

  describe "Statistics cards" do
    let!(:page1) { create(:alchemy_page, :public) }
    let!(:page2) { create(:alchemy_page) }

    it "displays statistics cards" do
      visit admin_dashboard_path
      stats_grid = find('.dashboard-stats-grid')
      expect(stats_grid).to have_content "Pages"
      expect(stats_grid).to have_content "Pictures"
      expect(stats_grid).to have_content "Attachments"
      expect(stats_grid).to have_content "Elements"
      expect(stats_grid).to have_content "Users"
      expect(stats_grid).to have_content "Languages"
    end
  end
end
