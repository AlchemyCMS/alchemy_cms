# frozen_string_literal: true

require "rails_helper"

describe "alchemy/_preview_mode_code.html.erb" do
  let(:page) { create(:alchemy_page) }

  context "in preview mode" do
    before { Alchemy::Current.preview_page = page }

    it "includes the preview javascript" do
      render partial: "alchemy/preview_mode_code"
      expect(rendered).to have_selector("script[src*='alchemy/preview']", visible: :all)
    end

    it "does not render an inline script" do
      render partial: "alchemy/preview_mode_code"
      expect(rendered).to_not have_selector("script:not([src])", visible: :all)
    end
  end

  context "outside of preview mode" do
    it "renders nothing" do
      render partial: "alchemy/preview_mode_code"
      expect(rendered).to be_blank
    end
  end
end
