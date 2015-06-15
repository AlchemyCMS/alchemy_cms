require 'spec_helper'

module Alchemy
  describe ElementsController do
    let(:public_page)         { create(:public_page) }
    let(:element)             { create(:element, page: public_page, name: 'download') }
    let(:restricted_page)     { create(:public_page, restricted: true) }
    let(:restricted_element)  { create(:element, page: restricted_page, name: 'download') }

    describe '#show' do
      it "should render available elements" do
        alchemy_get :show, id: element.id
        expect(response.status).to eq(200)
      end

      it "should raise ActiveRecord::RecordNotFound error for trashed elements" do
        element.trash!
        expect {
          alchemy_get :show, id: element.id
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "should raise ActiveRecord::RecordNotFound error for unpublished elements" do
        element.update_attributes(public: false)
        expect {
          alchemy_get :show, id: element.id
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      context "for guest user" do
        it "should raise ActiveRecord::RecordNotFound error for elements of restricted pages" do
          expect {
            alchemy_get :show, id: restricted_element.id
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "for member user" do
        before { authorize_user(build(:alchemy_dummy_user)) }

        it "should render elements of restricted pages" do
          alchemy_get :show, id: restricted_element.id
          expect(response.status).to eq(200)
        end
      end
    end
  end
end
