# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::Dashboard::Widgets::OnlineUsers, type: :component do
  let(:user) { build_stubbed(:alchemy_dummy_user, :as_admin) }

  before do
    allow(vc_test_view_context).to receive(:current_alchemy_user).and_return(user)
  end

  subject(:rendered) do
    render_inline(described_class.new)
    page
  end

  context "with user class not having logged_in scope" do
    it "does not render online_users" do
      rendered
      expect(page).to have_text(Alchemy.t("no users"))
    end
  end

  context "with user class having logged_in scope" do
    before do
      allow(Alchemy.config.user_class).to receive(:logged_in).and_return(users)
    end

    let(:users) { [] }

    context "with other users online" do
      let(:users) { [another_user] }

      let(:another_user) do
        mock_model("DummyUser", name: "Another User", human_roles_string: "Administrator")
      end

      it "renders online_users" do
        rendered
        expect(page).to have_text("Another User")
      end
    end

    context "without other users online" do
      let(:users) { [] }

      it "does not render online_users" do
        rendered
        expect(page).to have_text(Alchemy.t("no users"))
      end
    end
  end
end
