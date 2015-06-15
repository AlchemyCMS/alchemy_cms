require 'spec_helper'

describe 'Site select' do

  before do
    authorize_user(:as_admin)
  end

  it "does not display the site change" do
    visit admin_dashboard_path
    expect(page).not_to have_select('change_site')
  end

  context "multiple sites" do
    let!(:a_site) { FactoryGirl.create(:site) }

    it "contains all sites in a selectbox" do
      visit admin_dashboard_path
      expect(page).to have_select('change_site', options: [Alchemy::Site.default.name, a_site.name], selected: Alchemy::Site.default.name)
    end

    context 'when requesting non-default site' do
      it "provides the correct site" do
        visit admin_pages_path(site_id: a_site.id)
        expect(page).to have_select('change_site', selected: a_site.name)

        visit admin_dashboard_path
        expect(page).to have_select('change_site', selected: a_site.name)
      end
    end
  end
end
