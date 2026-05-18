# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::Dashboard::Widgets::RecentPages, type: :component do
  let(:user) { build_stubbed(:alchemy_dummy_user, :as_admin) }

  before do
    allow(vc_test_view_context).to receive(:multi_site?).and_return(false)
    allow(vc_test_view_context).to receive(:render_icon).and_return("icon")
    allow(vc_test_view_context).to receive(:current_alchemy_user).and_return(user)
    allow(Alchemy::Page).to receive(:all_last_edited_from).with(user) do
      pages
    end
  end

  subject(:rendered) do
    render_inline(described_class.new)
    page
  end

  context "when there are no recently edited pages" do
    let(:pages) { double(limit: []) }

    it "renders the widget with note" do
      expect(rendered).to have_css(".widget-body")
      expect(rendered).to have_text(Alchemy.t("no pages"))
    end
  end

  context "when there are recently edited pages" do
    let(:recent_page) do
      build_stubbed(:alchemy_page,
        name: "My Test Page",
        updated_at: 1.hour.ago,
        updater: user)
    end
    let(:pages) { double(limit: [recent_page]) }

    it "renders a link to each page" do
      expect(rendered).to have_link(recent_page.name)
    end

    context "with multiple sites" do
      before do
        allow(vc_test_view_context).to receive(:multi_site?).and_return(true)
      end

      it "renders site name" do
        expect(rendered).to have_text(recent_page.site_name)
      end

      context "and multiple languages" do
        before do
          allow(recent_page).to receive(:site_languages) do
            [
              build_stubbed(:alchemy_language, name: "English"),
              build_stubbed(:alchemy_language, name: "Deutsch")
            ]
          end
        end

        it "renders page language code" do
          expect(rendered).to have_text(recent_page.language.code.upcase)
        end
      end
    end
  end
end
