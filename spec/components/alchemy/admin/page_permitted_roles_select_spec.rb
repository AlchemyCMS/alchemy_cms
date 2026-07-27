# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::PagePermittedRolesSelect, type: :component do
  let(:alchemy_page) { build_stubbed(:alchemy_page, restricted: true) }
  let(:form) do
    Alchemy::Forms::Builder.new(:page, alchemy_page, vc_test_controller.view_context, {})
  end
  let(:component) { described_class.new(page: alchemy_page, form: form) }

  before do
    stub_alchemy_config(user_roles: %w[member restricted_test])
  end

  it "wraps the select in a conditional field bound to the restricted checkbox" do
    render_inline component
    expect(page).to have_css("alchemy-conditional-field[control='page_restricted']")
  end

  it "renders a tom select multi select of the configured roles" do
    render_inline component
    expect(page).to have_css("select[is='alchemy-select'][multiple][name='page[permitted_roles][]']")
    expect(page).to have_css("select option[value='member']", text: "Member")
    expect(page).to have_css("select option[value='restricted_test']", text: "Restricted Test")
  end

  it "marks the pages roles as selected" do
    allow(alchemy_page).to receive(:permitted_roles) { %w[restricted_test] }
    render_inline component
    expect(page).to have_css("select option[value='restricted_test'][selected]")
    expect(page).to_not have_css("select option[value='member'][selected]")
  end

  context "when the page has validation errors" do
    before do
      alchemy_page.permitted_roles = []
      alchemy_page.valid?
    end

    it "renders the error message" do
      render_inline component
      expect(page).to have_css(
        "small.error",
        text: "needs at least one role a restricted page is accessible for"
      )
    end
  end

  context "when the page holds a role that is not configured" do
    before do
      allow(alchemy_page).to receive(:permitted_roles) { %w[media_user] }
    end

    it "offers it as a selected option, so it survives the next save" do
      render_inline component
      expect(page).to have_css("select option[value='media_user'][selected]", text: "Media user")
      expect(page).to have_css("select option[value='member']")
    end
  end

  context "when the page is not restricted" do
    let(:alchemy_page) { build_stubbed(:alchemy_page, restricted: false) }

    it "disables the select so it does not clear the stored roles" do
      render_inline component
      expect(page).to have_css("select[disabled]")
    end
  end

  context "when the page is restricted" do
    it "enables the select" do
      render_inline component
      expect(page).to_not have_css("select[disabled]")
    end
  end

  context "when restricted is a fixed attribute" do
    before do
      allow(alchemy_page).to receive(:attribute_fixed?) { false }
      allow(alchemy_page).to receive(:attribute_fixed?).with(:restricted) { true }
    end

    it "disables the select" do
      render_inline component
      expect(page).to have_css("select[disabled]")
    end
  end
end
