# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::PublishPageButton, type: :component do
  let(:alchemy_page) { create(:alchemy_page) }
  let(:component) { described_class.new(page: alchemy_page) }

  before do
    allow_any_instance_of(described_class).to receive(:render_icon) do
      Alchemy::Admin::Icon.new("upload-cloud-2").call
    end
  end

  context "with publish permission" do
    before { allow(component).to receive(:cannot?) { false } }

    context "when @published is set to true" do
      let(:component) { described_class.new(page: alchemy_page, published: true) }

      it "shows no unpublished changes" do
        render_inline component
        expect(page).to have_css("sl-tooltip[content='No unpublished changes']")
      end
    end

    context "when @published is set to false" do
      context "with unpublished changes" do
        it "renders enabled button" do
          render_inline component
          expect(page).to have_css("sl-button")
          expect(page).not_to have_css("sl-button[disabled]")
        end

        it "shows tooltip with no unpublished changes" do
          render_inline component
          expect(page).to have_css("sl-tooltip[content='Publish current page content']")
        end
      end

      context "without unpublished changes" do
        let(:alchemy_page) { create(:alchemy_page, :public) }

        before do
          alchemy_page.public_version.update_column(:updated_at, 1.minute.from_now)
        end

        it "renders disabled button" do
          render_inline component
          expect(page).to have_css("sl-button[disabled]")
        end

        it "shows tooltip with no unpublished changes" do
          render_inline component
          expect(page).to have_css("sl-tooltip[content='No unpublished changes']")
        end
      end
    end
  end

  context "without publish permission" do
    before { allow(component).to receive(:cannot?) { true } }

    it "renders disabled button" do
      render_inline component
      expect(page).to have_css("sl-button[disabled]")
    end

    it "shows tooltip warning about permission" do
      render_inline component
      expect(page).to have_css("sl-tooltip[content='You have not the permission to publish this page']")
    end
  end

  describe "button label" do
    before { allow(component).to receive(:cannot?) { false } }

    context "when never published" do
      let(:alchemy_page) { create(:alchemy_page) }

      it "shows 'Publish page'" do
        render_inline component
        expect(page).to have_css("sl-button", text: "Publish page")
      end
    end

    context "when published" do
      let(:alchemy_page) { create(:alchemy_page, :public) }

      it "shows 'Publish changes'" do
        render_inline component
        expect(page).to have_css("sl-button", text: "Publish changes")
      end
    end
  end

  describe "tooltip content" do
    context "when pages language is not published" do
      let(:language) { create(:alchemy_language, default: false, public: false) }
      let(:alchemy_page) { create(:alchemy_page, language:) }

      it "shows warning about not public language" do
        render_inline component
        expect(page).to have_css("sl-tooltip[content='Cannot publish page if language is not public']")
      end
    end
  end
end
