# frozen_string_literal: true

require "spec_helper"

module Alchemy
  class NonArDummyUser; end

  describe FoldedPage do
    describe "folded_for_user" do
      subject(:folded_for_user) { described_class.folded_for_user(user) }
      let(:user) { create(:alchemy_dummy_user) }

      context "with a non-AR user_class" do
        around :each do |example|
          before = Alchemy.user_class_name
          Alchemy.user_class_name = "NonArDummyUser"
          example.run
          Alchemy.user_class_name = before
        end
        let(:user) { NonArDummyUser.new }

        it "does not raise an error" do
          expect {
            folded_for_user
          }.not_to raise_error
        end
      end

      context "with folded pages" do
        let(:page) { create(:alchemy_page) }
        let(:other_user) { create(:alchemy_dummy_user) }
        let!(:user_folded) { FoldedPage.create(user: user, page: page, folded: true) }
        let!(:other_user_folded) { FoldedPage.create(user: other_user, page: page, folded: true) }

        it { is_expected.to include(user_folded) }
        it { is_expected.to_not include(other_user_folded) }
      end
    end
  end
end
