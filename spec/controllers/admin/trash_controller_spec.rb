require 'spec_helper'

module Alchemy
  module Admin
    describe TrashController, :type => :controller do
      render_views

      let(:alchemy_page) { FactoryGirl.create(:public_page) }
      let(:element) { FactoryGirl.create(:element, :public => false, :page => alchemy_page) }

      before {
        sign_in(admin_user)
        element.trash!
      }

      it "should hold trashed elements" do
        get :index, :page_id => alchemy_page.id
        expect(response.body).to have_selector("#element_#{element.id}.element_editor")
      end

      it "should not hold elements that are not trashed" do
        element = FactoryGirl.create(:element, :page => alchemy_page, :public => false)
        get :index, :page_id => alchemy_page.id
        expect(response.body).not_to have_selector("#element_#{element.id}.element_editor")
      end

      context "with unique elements inside the trash" do
        let(:trashed) { FactoryGirl.build_stubbed(:unique_element, position: nil, public: false, folded: true, page: alchemy_page) }
        before { allow(Element).to receive(:trashed).and_return([trashed]) }

        context "and no unique elements on the page" do
          before { alchemy_page.stub_chain(:elements, :not_trashed, :pluck).and_return([]) }

          it "unique elements should be draggable" do
            get :index, page_id: alchemy_page.id
            expect(response.body).to have_selector("#element_#{trashed.id}.element_editor.draggable")
          end
        end

        context "and with an unique element on the page" do
          let(:unique) { FactoryGirl.build_stubbed(:unique_element) }
          let(:page) { FactoryGirl.build_stubbed(:public_page) }
          before {
            allow(Page).to receive(:find).and_return(page)
            page.stub_chain(:elements, :not_trashed, :pluck).and_return([unique.name])
          }

          it "unique elements should not be draggable" do
            get :index, page_id: page.id
            expect(response.body).to have_selector("#element_#{trashed.id}.element_editor.not-draggable")
          end
        end
      end

      describe "#clear" do
        it "should destroy all containing elements" do
          expect(Element.trashed).not_to be_empty
          xhr :post, :clear, page_id: alchemy_page.id
          expect(Element.trashed).to be_empty
        end
      end

    end
  end
end
