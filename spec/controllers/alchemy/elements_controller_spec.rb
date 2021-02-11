# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe ElementsController do
    routes { Alchemy::Engine.routes }

    let(:public_page)         { create(:alchemy_page, :public) }
    let(:element)             { create(:alchemy_element, page: public_page, name: "download") }
    let(:restricted_page)     { create(:alchemy_page, :public, restricted: true) }
    let(:restricted_element)  { create(:alchemy_element, page: restricted_page, name: "download") }

    describe "#show" do
      it "should render available elements" do
        get :show, params: {id: element.id}
        expect(response.status).to eq(200)
      end

      it "should raise ActiveRecord::RecordNotFound error for unpublished elements" do
        element.update_columns(public: false)
        expect {
          get :show, params: {id: element.id}
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      context "for guest user" do
        it "should raise ActiveRecord::RecordNotFound error for elements of restricted pages" do
          expect {
            get :show, params: {id: restricted_element.id}
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "for member user" do
        before { authorize_user(build(:alchemy_dummy_user)) }

        it "should render elements of restricted pages" do
          get :show, params: {id: restricted_element.id}
          expect(response.status).to eq(200)
        end
      end
    end
  end
end
