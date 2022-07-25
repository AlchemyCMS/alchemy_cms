# frozen_string_literal: true

require "rails_helper"
require "timecop"

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

  describe "#destroy" do
    let(:page) { create(:alchemy_page) }

    context "with nodes attached" do
      let!(:node) { create(:alchemy_node, page: page) }

      it "returns with error message" do
        delete :destroy, params: { id: page.id, format: :js }
        expect(response).to redirect_to admin_page_path(page.id)
        expect(flash[:warning]).to \
          eq("Nodes are still attached to this page. Please remove them first.")
      end
    end

    context "without nodes" do
      it "removes the page" do
        delete :destroy, params: { id: page.id, format: :js }
        expect(response).to redirect_to admin_page_path(page.id)
        expect(flash[:notice]).to eq("A Page 61 deleted")
      end
    end
  end

  describe "#publish" do
    let(:page) { create(:alchemy_page) }

    it "publishes the page" do
      current_time = Time.current
      Timecop.freeze(current_time) do
        expect {
          post :publish, params: { id: page }
        }.to have_enqueued_job(Alchemy::PublishPageJob).with(page.id, public_on: current_time)
      end
    end
  end
end
