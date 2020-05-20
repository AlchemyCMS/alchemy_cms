# frozen_string_literal: true

require "rails_helper"

module Alchemy
  module Admin
    describe TrashController do
      routes { Alchemy::Engine.routes }

      render_views

      let(:page) { create(:alchemy_page, :public) }
      let!(:trashed) { create(:alchemy_element, :trashed, page: page) }
      let!(:element) { create(:alchemy_element, page: page) }

      before do
        authorize_user(:as_admin)
      end

      it "lists trashed elements" do
        get :index, params: {page_id: page.id}
        expect(response.body).to have_selector("[data-element-id=\"#{trashed.id}\"].element-editor")
      end

      it "does not list elements that are not trashed" do
        get :index, params: {page_id: page.id}
        expect(response.body).not_to have_selector("[data-element-id=\"#{element.id}\"].element-editor")
      end

      context "with unique elements inside the trash" do
        let!(:unique_trashed) { create(:alchemy_element, :trashed, :unique, page: page) }

        context "and no unique elements on the page" do
          let!(:not_unique) do
            create(:alchemy_element, page: page)
          end

          it "unique elements should be draggable" do
            get :index, params: {page_id: page.id}
            expect(response.body).to have_selector("[data-element-id=\"#{unique_trashed.id}\"].element-editor.draggable")
          end
        end

        context "and with an unique element on the page" do
          let!(:unique) { create(:alchemy_element, :unique, page: page) }

          it "unique elements should not be draggable" do
            get :index, params: {page_id: page.id}
            expect(response.body).to have_selector("[data-element-id=\"#{unique_trashed.id}\"].element-editor.not-draggable")
          end
        end
      end

      describe "#clear" do
        it "should destroy all containing elements" do
          expect(Element.trashed).not_to be_empty
          post :clear, params: {page_id: page.id}, xhr: true
          expect(Element.trashed).to be_empty
        end
      end
    end
  end
end
