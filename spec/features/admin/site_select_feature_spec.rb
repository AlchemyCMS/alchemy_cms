# frozen_string_literal: true

require 'spec_helper'

describe 'Site select' do
  before do
    authorize_user(:as_admin)
  end

  context "without multiple sites" do
    it "does not display the site select" do
      visit admin_pages_path
      expect(page).not_to have_select('change_site')
    end
  end

  context "with multiple sites" do
    let!(:default_site) { create(:alchemy_site, :default) }
    let!(:a_site) { create(:alchemy_site) }

    context "not on pages or languages module" do
      it "does not display the site select" do
        visit admin_dashboard_path
        expect(page).not_to have_select('change_site')
      end
    end

    context "on pages and languages module" do
      it "contains all sites in a selectbox" do
        %w(admin_pages_path admin_layoutpages_path admin_languages_path).each do |module_path|
          visit send(module_path)
          expect(page).to have_select('change_site',
            options: [Alchemy::Site.default.name, a_site.name],
            selected: Alchemy::Site.default.name)
        end
      end
    end

    context 'when switching site' do
      it "stores the site in session" do
        visit admin_pages_path(site_id: a_site.id)
        expect(page).to have_select('change_site', selected: a_site.name)

        visit admin_languages_path
        expect(page).to have_select('change_site', selected: a_site.name)
      end

      context 'when site id is not found' do
        it "stores the default site in session" do
          visit admin_pages_path(site_id: '')
          expect(page).to have_select('change_site', selected: Alchemy::Site.default.name)
        end
      end
    end
  end
end
