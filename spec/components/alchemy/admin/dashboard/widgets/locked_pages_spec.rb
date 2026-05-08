# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::Dashboard::Widgets::LockedPages, type: :component do
  let(:user) { build_stubbed(:alchemy_dummy_user, :as_editor) }
  let(:pages) { [] }

  before do
    vc_test_view_context.class.include Alchemy::Admin::BaseHelper
    allow(vc_test_view_context).to receive(:multi_site?).and_return(false)
    allow(Alchemy::Page).to receive(:locked) do
      pages
    end
  end

  subject(:rendered) do
    render_inline(described_class.new(user:))
    page
  end

  context "when there are no locked pages" do
    let(:pages) { [] }

    it "renders the widget with note" do
      expect(rendered).to have_css(".widget")
      expect(rendered).to have_text(Alchemy.t("no pages"))
    end
  end

  context "when there are locked pages" do
    let(:locked_page) do
      build_stubbed(:alchemy_page,
        name: "My Test Page",
        updated_at: 1.hour.ago,
        locker: build_stubbed(:alchemy_dummy_user, name: "John Doe"),
        updater: user)
    end
    let(:pages) { [locked_page] }

    it "renders each page name" do
      expect(rendered).to have_text(locked_page.name)
    end

    it "renders page locker name" do
      expect(rendered).to have_text(locked_page.locker_name)
    end

    context "and locker is user" do
      before do
        allow(locked_page).to receive(:locked_by) { user.id }
      end

      it "renders a link to each page" do
        expect(rendered).to have_link(locked_page.name)
      end

      it "renders note about user is locker" do
        expect(rendered).to have_text(Alchemy.t(:me))
      end
    end

    context "and user is site manager" do
      before do
        allow(vc_test_view_context).to receive(:can?).with(:manage, locked_page.site) { true }
      end

      it "renders button to unlock page" do
        expect(rendered).to have_css("button[title='#{Alchemy.t(:explain_unlocking)}']")
      end
    end

    context "with multiple sites" do
      before do
        allow(vc_test_view_context).to receive(:multi_site?).and_return(true)
      end

      it "renders site name" do
        expect(rendered).to have_text(locked_page.site_name)
      end

      context "and multiple languages" do
        before do
          allow(locked_page).to receive(:site_languages) do
            [
              build_stubbed(:alchemy_language, name: "English"),
              build_stubbed(:alchemy_language, name: "Deutsch")
            ]
          end
        end

        it "renders page language code" do
          expect(rendered).to have_text(locked_page.language.code.upcase)
        end
      end
    end
  end
end
