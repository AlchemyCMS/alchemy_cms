# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::ElementsController do
  before do
    authorize_user(:as_admin)
  end

  describe "#collapse" do
    context "collapse element with ingredients" do
      let(:element) { create(:alchemy_element, :with_ingredients, folded: true) }

      context "with validations" do
        let(:element) { create(:alchemy_element, :with_ingredients, name: :all_you_can_eat) }

        it "saves without running validations" do
          post collapse_admin_element_path(id: element.id, format: :js)
          expect(element.reload).to be_folded
        end
      end
    end
  end

  describe "#publish" do
    context "publish element" do
      context "with validations" do
        let(:element) { create(:alchemy_element, :with_ingredients, name: :all_you_can_eat, public: false) }

        it "saves without running validations" do
          patch publish_admin_element_path(id: element.id, format: :js)
          expect(element.reload).to be_public
        end
      end
    end
  end

  describe "#update" do
    let(:element) { create(:alchemy_element) }

    context "if validation failed" do
      before do
        allow_any_instance_of(Alchemy::Element).to receive(:update).and_return(false)
      end

      it "returns 422 status" do
        patch admin_element_path(id: element.id)
        expect(response.status).to eq 422
      end
    end

    context "if validation succeeded" do
      it "returns publishButtonTooltip" do
        patch admin_element_path(id: element.id)
        expect(response.parsed_body["publishButtonTooltip"]).to eq(Alchemy.t(:explain_publishing))
      end
    end
  end
end
