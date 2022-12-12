# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Api::IngredientsController do
  routes { Alchemy::Engine.routes }

  describe "#index" do
    let(:page) { create(:alchemy_page) }
    let(:element) { create(:alchemy_element, page_version: page.draft_version) }
    let!(:ingredient) { create(:alchemy_ingredient_text, element: element) }

    context "as guest user" do
      it "returns no ingredients" do
        get :index, params: { format: :json }

        expect(response.status).to eq(200)
        expect(response.media_type).to eq("application/json")

        result = JSON.parse(response.body)

        expect(result).to have_key("ingredients")
        expect(result["ingredients"].size).to be_zero
      end
    end

    context "as author" do
      before do
        authorize_user(build(:alchemy_dummy_user, :as_author))
      end

      it "returns all ingredients" do
        get :index, params: { format: :json }

        expect(response.status).to eq(200)
        expect(response.media_type).to eq("application/json")

        result = JSON.parse(response.body)

        expect(result).to have_key("ingredients")
        expect(result["ingredients"].size).to eq Alchemy::Ingredient.count
      end

      context "with page_id" do
        let(:public_page) { create(:alchemy_page, :public) }
        let(:other_draft_element) { create(:alchemy_element, page_version: public_page.draft_version) }
        let(:other_public_element) { create(:alchemy_element, page_version: public_page.public_version) }
        let!(:other_draft_ingredient) { create(:alchemy_ingredient_text, element: other_draft_element) }
        let!(:other_public_ingredient) { create(:alchemy_ingredient_text, element: other_public_element) }

        it "returns only draft ingredients from this page" do
          get :index, params: { page_id: public_page.id, format: :json }

          expect(response.status).to eq(200)
          expect(response.media_type).to eq("application/json")

          result = JSON.parse(response.body)

          expect(result).to have_key("ingredients")
          expect(result["ingredients"].size).to eq(1)
          expect(result["ingredients"][0]["element_id"]).to eq(other_draft_element.id)
        end
      end
    end
  end
end
