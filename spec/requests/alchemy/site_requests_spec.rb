# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Site requests" do
  let(:language) { create(:alchemy_language, site: site) }

  let(:page) do
    Alchemy::Site.current = site
    root = create(:alchemy_page, :language_root, language: language)
    create(:alchemy_page, :public, parent: root)
  end

  context "a site with host" do
    let!(:site) { create(:alchemy_site, :public, host: "alchemy-cms.com") }

    it "loads this site by host" do
      get "http://#{site.host}/#{page.urlname}"
      expect(assigns(:current_alchemy_site).host).to eq(site.host)
    end
  end

  context "a site with alias and redirecting to primary host" do
    let!(:site) do
      create(
        :alchemy_site,
        :public,
        host: "real.example.com",
        aliases: "something.alchemy-cms.com",
        redirect_to_primary_host: true
      )
    end

    context "requested by alias host" do
      it "redirects to primary host" do
        get "http://something.alchemy-cms.com/#{page.urlname}"
        expect(response).to redirect_to("http://real.example.com/#{page.urlname}")
      end
    end
  end
end
