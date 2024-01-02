# frozen_string_literal: true

require "rails_helper"

RSpec.describe "TinyMCE Editor", type: :system do
  before do
    authorize_user(:as_admin)
  end

  it "base path should be set to tinymce asset folder" do
    visit admin_dashboard_path
    expect(page).to have_content(
      "var tinyMCEPreInit = { base: '/assets/tinymce', suffix: '.min' };"
    )
  end

  context "with asset host" do
    around do |example|
      host = ActionController::Base.config.asset_host
      ActionController::Base.config.asset_host = "myhost.com"
      example.run
      ActionController::Base.config.asset_host = host
    end

    it "base path should be set to tinymce asset folder" do
      visit admin_dashboard_path
      expect(page).to have_content(
        "var tinyMCEPreInit = { base: 'http://myhost.com/assets/tinymce', suffix: '.min' };"
      )
    end
  end

  describe "assets preloading" do
    it "should preload assets" do
      visit admin_dashboard_path
      expect(page)
        .to have_css('link[rel="preload"][href="/assets/tinymce/skins/ui/alchemy/skin.min.css"]')
    end

    context "with asset host" do
      around do |example|
        host = ActionController::Base.config.asset_host
        ActionController::Base.config.asset_host = "https://myhost.com"
        example.run
        ActionController::Base.config.asset_host = host
      end

      it "should preload assets from host" do
        visit admin_dashboard_path
        expect(page)
          .to have_css('link[rel="preload"][href="https://myhost.com/assets/tinymce/skins/ui/alchemy/skin.min.css"]')
      end
    end

    context "when content_css is configured" do
      before do
        Alchemy::Tinymce.init = {content_css: "/assets/custom-stylesheet.css"}
      end

      it "should preload it" do
        visit admin_dashboard_path
        expect(page)
          .to have_css('link[rel="preload"][href="/assets/custom-stylesheet.css"]')
      end

      context "with asset host" do
        around do |example|
          host = ActionController::Base.config.asset_host
          ActionController::Base.config.asset_host = "https://myhost.com"
          example.run
          ActionController::Base.config.asset_host = host
        end

        it "should preload it from host" do
          visit admin_dashboard_path
          expect(page)
            .to have_css('link[rel="preload"][href="https://myhost.com/assets/custom-stylesheet.css"]')
        end
      end
    end
  end
end
