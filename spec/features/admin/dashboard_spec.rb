require 'spec_helper'

describe 'Dashboard feature' do
  let(:a_page) { FactoryGirl.create(:public_page, visible: true) }

  before do
    @user = DummyUser.new
    @user.update_attributes(alchemy_roles: %w(admin), name: "Joe User", id: 1)
    authorize_as_admin(@user)
  end

  describe 'Locked pages summary' do
    it "should initially show no pages are locked" do
      visit admin_dashboard_path
      locked_pages_widget = all('div[@class="widget"]').first
      expect(locked_pages_widget).to have_content "Currently locked pages:"
      expect(locked_pages_widget).to have_content "no pages"
    end

    context 'When locked by current user' do
      it "should show locked by me" do
        a_page.lock_to!(@user)
        visit admin_dashboard_path
        locked_pages_widget = all('div[@class="widget"]').first
        expect(locked_pages_widget).to have_content "Currently locked pages:"
        expect(locked_pages_widget).to have_content a_page.name
        expect(locked_pages_widget).to have_content "Me"
      end
    end

    context 'When locked by another user' do
      it "should show locked by user's name" do
        user = DummyUser.new
        user.update_attributes(alchemy_roles: %w(admin), name: "Sue Smith", id: 2)
        a_page.lock_to!(user)
        DummyUser.stub(:find_by).and_return(user)
        visit admin_dashboard_path
        locked_pages_widget = all('div[@class="widget"]').first
        expect(locked_pages_widget).to have_content "Currently locked pages:"
        expect(locked_pages_widget).to have_content a_page.name
        expect(locked_pages_widget).to have_content "Sue Smith"
      end
    end
  end
end
