# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::Dashboard::Widgets::Sites, type: :component do
  let(:user) { build_stubbed(:alchemy_dummy_user, :as_admin) }

  before do
    allow(vc_test_view_context).to receive(:current_alchemy_user).and_return(user)
  end

  subject(:rendered) do
    render_inline(described_class.new)
    page
  end

  context "with multiple sites" do
    let!(:default_site) { create(:alchemy_site, :default) }
    let!(:another_site) { create(:alchemy_site, name: "Site", host: "site.com") }

    it "lists all sites" do
      rendered
      expect(page).to have_content "Websites"
      expect(page).to have_content "Default Site"
      expect(page).to have_content "Site"
    end

    context "with alchemy url proxy object having `login_url`" do
      before do
        allow_any_instance_of(ActionDispatch::Routing::RoutesProxy).to receive(:login_url).and_return("http://site.com/admin/login")
      end

      it "links to login page of every site" do
        rendered
        expect(page).to have_selector 'a[href="http://site.com/admin/login"]'
      end
    end
  end
end
