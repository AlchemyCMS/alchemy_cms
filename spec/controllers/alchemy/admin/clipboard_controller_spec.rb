# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Admin::ClipboardController do
    routes { Alchemy::Engine.routes }

    let(:element)         { build_stubbed(:alchemy_element) }
    let(:another_element) { build_stubbed(:alchemy_element) }

    before do
      authorize_user(:as_admin)
      session[:alchemy_clipboard] = {}
    end

    describe "#index" do
      context "with `remarkable_type` being an allowed type" do
        it "is successful" do
          get :index, params: {remarkable_type: "elements"}
          expect(response).to be_successful
        end
      end

      context "with `remarkable_type` not an allowed type" do
        it "raises 400 Bad Request" do
          expect {
            get :index, params: {remarkable_type: "evil"}
          }.to raise_error(ActionController::BadRequest)
        end
      end
    end

    context "for elements" do
      before do
        expect(Element).to receive(:find).and_return(element)
      end

      describe "#insert" do
        it "should hold element ids" do
          post :insert, params: {remarkable_type: "elements", remarkable_id: element.id}, xhr: true
          expect(session[:alchemy_clipboard]["elements"]).to eq([{"id" => element.id.to_s, "action" => "copy"}])
        end

        it "should not have the same element twice" do
          session[:alchemy_clipboard]["elements"] = [{"id" => element.id.to_s, "action" => "copy"}]
          post :insert, params: {remarkable_type: "elements", remarkable_id: element.id}, xhr: true
          expect(session[:alchemy_clipboard]["elements"].collect { |e| e["id"] }).not_to eq([element.id, element.id])
        end
      end

      describe "#delete" do
        it "should remove element ids from clipboard" do
          session[:alchemy_clipboard]["elements"] = [{"id" => element.id.to_s, "action" => "copy"}]
          session[:alchemy_clipboard]["elements"] << {"id" => another_element.id.to_s, "action" => "copy"}
          delete :remove, params: {remarkable_type: "elements", remarkable_id: another_element.id}, xhr: true
          expect(session[:alchemy_clipboard]["elements"]).to eq([{"id" => element.id.to_s, "action" => "copy"}])
        end
      end
    end

    describe "#clear" do
      context "with elements as remarkable_type" do
        it "should clear the elements clipboard" do
          session[:alchemy_clipboard]["elements"] = [{"id" => element.id.to_s}]
          delete :clear, params: {remarkable_type: "elements"}, xhr: true
          expect(session[:alchemy_clipboard]["elements"]).to be_empty
        end
      end

      context "with pages as remarkable_type" do
        let(:public_page) { build_stubbed(:alchemy_page, :public) }

        it "should clear the pages clipboard" do
          session[:alchemy_clipboard]["pages"] = [{"id" => public_page.id.to_s}]
          delete :clear, params: {remarkable_type: "pages"}, xhr: true
          expect(session[:alchemy_clipboard]["pages"]).to be_empty
        end
      end
    end
  end
end
