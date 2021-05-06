# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::PagesController do
  routes { Alchemy::Engine.routes }

  before do
    authorize_user(:as_admin)
  end

  describe "#index" do
    let!(:page) { create(:alchemy_page) }

    context "with params[:view] set" do
      subject! { get(:index, params: { view: "list" }) }

      it "sets view to that value" do
        expect(session[:alchemy_pages_view]).to eq("list")
        expect(assigns[:view]).to eq("list")
      end
    end

    context "with params[:view] not set" do
      subject { get(:index) }

      context "with session[:view] not set" do
        it "uses tree view" do
          subject
          expect(session[:alchemy_pages_view]).to eq("tree")
          expect(assigns[:view]).to eq("tree")
        end
      end

      context "with session[:view] set" do
        before do
          session[:alchemy_pages_view] = "list"
        end

        it "uses the view from session" do
          subject
          expect(session[:alchemy_pages_view]).to eq("list")
          expect(assigns[:view]).to eq("list")
        end
      end
    end
  end

  describe "#publish" do
    let(:page) { create(:alchemy_page) }

    it "publishes the page" do
      expect_any_instance_of(Alchemy::Page).to receive(:publish!)
      post :publish, params: { id: page }
    end
  end
end
