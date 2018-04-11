# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Site requests' do
  context 'a site with host' do
    let!(:site) { create(:alchemy_site, :public, host: 'alchemy-cms.com') }

    let(:page) do
      Alchemy::Site.current = site
      root = create(:alchemy_page, :language_root, language: site.languages.last)
      create(:alchemy_page, :public, parent: root)
    end

    it 'loads this site by host' do
      get "http://#{site.host}/#{page.urlname}"
      expect(assigns(:current_alchemy_site).host).to eq(site.host)
    end
  end
end
