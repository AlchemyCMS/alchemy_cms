# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::Dashboard::Widgets::Greeting, type: :component do
  let(:user) { build_stubbed(:alchemy_dummy_user, :as_admin) }

  subject(:rendered) do
    render_inline(described_class.new(user:))
    page
  end

  it "displays user name" do
    rendered
    expect(page).to have_css(".user-name", text: user.alchemy_display_name)
  end

  context "user has not signed in before" do
    before do
      expect(user).to receive(:sign_in_count).and_return(1)
      expect(user).to receive(:last_sign_in_at).and_return(nil)
    end

    it "displays welcome_note" do
      rendered
      expect(page).to have_content Alchemy.t(:welcome_note, name: "")
    end
  end

  context "user has signed in before" do
    before do
      expect(user).to receive(:sign_in_count).and_return(5)
      expect(user).to receive(:last_sign_in_at).and_return(Time.current)
    end

    it "displays welcome_back_note" do
      rendered
      expect(page).to have_content Alchemy.t(:welcome_back_note, name: "")
    end
  end
end
