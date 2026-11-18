# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::UserMenu, type: :component do
  before do
    allow(vc_test_request).to receive(:path) { "/admin/dashboard" }
    allow(Alchemy::I18n).to receive(:available_locales) { locales }
  end

  let(:locales) { %i[de en] }

  subject(:render) do
    render_inline described_class.new(user:)
    rendered_content
  end

  context "without a user" do
    let(:user) { nil }

    it { expect(render).to be_blank }
  end

  context "with a user" do
    let(:user) { double("User", id: 42, alchemy_display_name: "Peter Schroeder") }

    before { render }

    it "shows the initial of the user's name as avatar in the trigger" do
      expect(page).to have_selector("alchemy-user-menu.user-menu sl-dropdown [slot='trigger'] .user-avatar", text: "P")
    end

    it "shows the user's name with the current timezone and language in the trigger" do
      expect(page).to have_selector("[slot='trigger'] .user-menu-name", text: "Peter Schroeder")
      expect(page).to have_selector("[slot='trigger'] .user-menu-meta", text: "#{Time.zone.name} · EN")
    end

    it "opens the menu next to the main menu" do
      expect(page).to have_selector("sl-dropdown[placement='right-end']")
    end

    it "lists the user's name" do
      expect(page).to have_selector(".user-menu .current-user-name", text: "Peter Schroeder")
    end

    it "contains the timezone select without its own dropdown" do
      expect(page).to have_selector(".user-menu select[name='admin_timezone']")
      expect(page).to have_selector("sl-dropdown", count: 1)
    end

    it "contains the locale select with a label" do
      expect(page).to have_selector(".user-menu label[for='admin_locale']", text: "Language")
      expect(page).to have_selector(".user-menu select[name='admin_locale']")
    end

    context "with only one available locale" do
      let(:locales) { %i[en] }

      it "does not render the locale select" do
        expect(page).not_to have_selector("label[for='admin_locale']")
        expect(page).not_to have_selector("select[name='admin_locale']")
      end
    end
  end

  context "with a user without a display name" do
    let(:user) { double("User", id: 42, alchemy_display_name: "") }

    it "shows a user icon as avatar" do
      render
      expect(page).to have_selector(".user-avatar alchemy-icon[name='user']")
    end
  end
end
