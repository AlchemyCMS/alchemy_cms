# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::Dashboard::Widgets::UserCounts, type: :component do
  subject(:rendered) do
    render_inline(described_class.new)
    page
  end

  context "without any users" do
    it "renders zero count" do
      expect(rendered).to have_css(".widget-body")
      expect(rendered).to have_css(".count", text: "0")
    end
  end

  context "with users" do
    before do
      create_list(:alchemy_dummy_user, 2)
    end

    it "renders the total count of users" do
      expect(rendered).to have_css(".count", text: "2")
    end
  end

  it "renders the title" do
    expect(rendered).to have_text(Alchemy.user_class.model_name.human(count: :many))
  end

  it "renders the icon" do
    expect(rendered).to have_css('alchemy-icon[name="group"]')
  end

  context "with an admin_users_path configured" do
    before do
      allow(Alchemy.config).to receive(:admin_users_path).and_return("/admin/users")
    end

    it "renders a link to the users admin" do
      expect(rendered).to have_link(href: "/admin/users")
    end
  end

  context "with user class responding to logged_in" do
    before do
      allow(Alchemy.config.user_class).to receive(:respond_to?).and_call_original
      allow(Alchemy.config.user_class).to receive(:respond_to?).with(:logged_in).and_return(true)
      allow(Alchemy.config.user_class).to receive(:logged_in).and_return([double(:user), double(:user)])
    end

    it "renders the count of online users" do
      expect(rendered).to have_css(".infos", text: "2 #{Alchemy.t("online", scope: "admin.dashboard.widgets.user_counts")}")
    end
  end

  context "with user class not responding to logged_in" do
    before do
      allow(Alchemy.config.user_class).to receive(:respond_to?).and_call_original
      allow(Alchemy.config.user_class).to receive(:respond_to?).with(:logged_in).and_return(false)
    end

    it "does not render the infos section" do
      expect(rendered).to have_no_css(".infos")
    end
  end
end
