# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe SitemapController do
    routes { Alchemy::Engine.routes }

    let!(:page) { create(:alchemy_page, :public, sitemap: true) }

    describe "#show" do
      # The template stays at its old path for the deprecation window, so that
      # apps overriding it keep getting their own version rendered.
      it "renders the pages sitemap template" do
        expect(get(:show, format: :xml)).to render_template("alchemy/pages/sitemap")
      end
    end
  end
end
