# frozen_string_literal: true

require 'spec_helper'

module Alchemy
  module Admin
    describe TrashController do
      routes { Alchemy::Engine.routes }

      render_views

      let(:alchemy_page) { create(:alchemy_page, :public) }
      let(:element) { create(:alchemy_element, public: false, page: alchemy_page) }

      before {
        authorize_user(:as_admin)
        element.trash!
      }

      it "should hold trashed elements" do
        get :index, params: {page_id: alchemy_page.id}
        expect(response.body).to have_selector("#element_#{element.id}.element-editor")
      end

      it "should not hold elements that are not trashed" do
        element = create(:alchemy_element, page: alchemy_page, public: false)
        get :index, params: {page_id: alchemy_page.id}
        expect(response.body).not_to have_selector("#element_#{element.id}.element-editor")
      end

      context "with unique elements inside the trash" do
        let(:trashed) { build_stubbed(:alchemy_element, :unique, position: nil, public: false, folded: true, page: alchemy_page) }
        before { allow(Element).to receive(:trashed).and_return([trashed]) }

        context "and no unique elements on the page" do
          before do
            allow(alchemy_page).to receive(:elements).and_return double(not_trashed: double(pluck: []))
          end

          it "unique elements should be draggable" do
            get :index, params: {page_id: alchemy_page.id}
            expect(response.body).to have_selector("#element_#{trashed.id}.element-editor.draggable")
          end
        end

        context "and with an unique element on the page" do
          let(:unique) { build_stubbed(:alchemy_element, :unique) }
          let(:page) { build_stubbed(:alchemy_page, :public) }

          before do
            allow(Page).to receive(:find).and_return(page)
            allow(page).to receive(:elements).and_return double(not_trashed: double(pluck: [unique.name]))
          end

          it "unique elements should not be draggable" do
            get :index, params: {page_id: page.id}
            expect(response.body).to have_selector("#element_#{trashed.id}.element-editor.not-draggable")
          end
        end
      end

      describe "#clear" do
        it "should destroy all containing elements" do
          expect(Element.trashed).not_to be_empty
          post :clear, params: {page_id: alchemy_page.id}, xhr: true
          expect(Element.trashed).to be_empty
        end
      end
    end
  end
end
