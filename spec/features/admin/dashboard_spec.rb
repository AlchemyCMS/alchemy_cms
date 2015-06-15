require 'spec_helper'

describe 'Dashboard feature' do
  let(:user) { create(:alchemy_dummy_user, :as_admin, name: "Joe User") }

  before do
    authorize_user(user)
  end

  describe 'Locked pages summary' do
    let(:a_page) { FactoryGirl.create(:public_page, visible: true) }

    it "should initially show no pages are locked" do
      visit admin_dashboard_path
      locked_pages_widget = all('div[@class="widget"]').first
      expect(locked_pages_widget).to have_content "Currently locked pages:"
      expect(locked_pages_widget).to have_content "no pages"
    end

    context 'When locked by current user' do
      it "should show locked by me" do
        a_page.lock_to!(user)
        visit admin_dashboard_path
        locked_pages_widget = all('div[@class="widget"]').first
        expect(locked_pages_widget).to have_content "Currently locked pages:"
        expect(locked_pages_widget).to have_content a_page.name
        expect(locked_pages_widget).to have_content "Me"
      end
    end

    context 'When locked by another user' do
      let(:other_user) { create(:alchemy_dummy_user, :as_admin, name: "Sue Smith") }

      it "shows the name of the user who locked the page" do
        a_page.lock_to!(other_user)
        allow(user.class).to receive(:find_by).and_return(other_user)
        visit admin_dashboard_path
        locked_pages_widget = all('div[@class="widget"]').first
        expect(locked_pages_widget).to have_content "Currently locked pages:"
        expect(locked_pages_widget).to have_content a_page.name
        expect(locked_pages_widget).to have_content "Sue Smith"
      end
    end
  end

  describe 'Sites widget' do
    context 'with multiple sites' do

      before do
        Alchemy::Site.create!(name: 'Site', host: 'site.com')
      end

      it "lists all sites" do
        visit admin_dashboard_path
        sites_widget = all('div[@class="widget sites"]').first
        expect(sites_widget).to have_content "Websites:"
        expect(sites_widget).to have_content "Default Site"
        expect(sites_widget).to have_content "Site"
      end

      context 'with alchemy url proxy object having `login_url`' do
        before do
          allow_any_instance_of(ActionDispatch::Routing::RoutesProxy).to receive(:login_url).and_return('http://site.com/admin/login')
        end

        it "links to login page of every site" do
          visit admin_dashboard_path
          sites_widget = all('div[@class="widget sites"]').first
          expect(sites_widget).to have_selector 'a[href="http://site.com/admin/login"]'
        end
      end
    end

    context 'with only one site' do
      it "does not display" do
        visit admin_dashboard_path
        sites_widget = all('div[@class="widget sites"]').first
        expect(sites_widget).to be_nil
      end
    end
  end
end
