# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe SitemapController do
    routes { Alchemy::Engine.routes }

    let!(:page) { create(:alchemy_page, :public, sitemap: true) }

    describe "#show" do
      it "renders the sitemap show template" do
        expect(get(:show, format: :xml)).to render_template("alchemy/sitemap/show")
      end

      context "when the app overrides the template at its legacy path" do
        let(:legacy_dir) { Rails.root.join("app/views/alchemy/pages") }
        let(:legacy_template) { legacy_dir.join("sitemap.xml.erb") }

        before do
          ActionView::LookupContext::DetailsKey.clear
          FileUtils.mkdir_p(legacy_dir)
          File.write(legacy_template, "<url><loc>legacy</loc></url>")
        end

        after do
          FileUtils.rm_f(legacy_template)
          Dir.rmdir(legacy_dir) if Dir.empty?(legacy_dir)
          ActionView::LookupContext::DetailsKey.clear
        end

        it "renders the legacy template and warns about the deprecation" do
          expect(Alchemy::Deprecation).to receive(:warn).with(/alchemy\/pages\/sitemap` is deprecated/)
          expect(get(:show, format: :xml)).to render_template("alchemy/pages/sitemap")
        end
      end
    end
  end
end
