# frozen_string_literal: true

require "rails_helper"

RSpec.describe "TinyMCE Editor", type: :system do
  before do
    authorize_user(:as_admin)
  end

  let(:cache_suffix) { Alchemy::Tinymce.cache_suffix(ActionController::Base.helpers) }

  it "base path should be set to tinymce asset folder" do
    visit admin_dashboard_path
    expect(page).to have_css(
      "script#alchemy_tinymce_defaults",
      text: '"base_url":"/assets/tinymce","suffix":".min"',
      visible: false
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
      expect(page).to have_css(
        "script#alchemy_tinymce_defaults",
        text: '"base_url":"http://myhost.com/assets/tinymce","suffix":".min"',
        visible: false
      )
    end
  end

  describe "cache suffix" do
    it "is set to the digest of the skin stylesheets" do
      visit admin_dashboard_path
      expect(page).to have_css(
        "script#alchemy_tinymce_defaults",
        text: %("cache_suffix":"#{cache_suffix}"),
        visible: false
      )
    end

    it "is appended to the skin stylesheets Tinymce loads", :js do
      visit admin_styleguide_path
      expect(page).to have_css("alchemy-tinymce .tox-tinymce")
      hrefs = page.evaluate_script(
        "Array.from(document.querySelectorAll('link[rel=stylesheet]')).map((l) => l.href)"
      )
      expect(hrefs).to include(
        a_string_ending_with("/assets/tinymce/skins/ui/alchemy/skin.min.css?#{cache_suffix}")
      )
    end
  end

  describe "assets preloading" do
    it "should preload assets" do
      visit admin_dashboard_path
      expect(page)
        .to have_css(%(link[rel="preload"][href="/assets/tinymce/skins/ui/alchemy/skin.min.css?#{cache_suffix}"]))
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
          .to have_css(%(link[rel="preload"][href="https://myhost.com/assets/tinymce/skins/ui/alchemy/skin.min.css?#{cache_suffix}"]))
      end
    end

    context "with an asset host proc that asks for the request" do
      around do |example|
        host = ActionController::Base.asset_host
        ActionController::Base.asset_host = ->(_source, request) { "https://#{request.host}" }
        example.run
        ActionController::Base.asset_host = host
      end

      it "should preload assets from the host the proc builds" do
        visit admin_dashboard_path
        expect(page)
          .to have_css(%(link[rel="preload"][href^="https://www.example.com/assets/tinymce/skins/ui/alchemy/skin.min.css?"]))
      end
    end

    context "when content_css is configured" do
      before do
        Alchemy::Tinymce.init = {content_css: "/assets/custom-stylesheet.css"}
      end

      it "should preload it" do
        visit admin_dashboard_path
        expect(page)
          .to have_css(%(link[rel="preload"][href="/assets/custom-stylesheet.css?#{cache_suffix}"]))
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
            .to have_css(%(link[rel="preload"][href="https://myhost.com/assets/custom-stylesheet.css?#{cache_suffix}"]))
        end
      end
    end
  end
end
