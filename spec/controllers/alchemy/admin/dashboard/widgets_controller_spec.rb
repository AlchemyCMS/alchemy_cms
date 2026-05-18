# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Admin::Dashboard::WidgetsController do
    routes { Alchemy::Engine.routes }

    let(:user) { build_stubbed(:alchemy_dummy_user, :as_admin) }

    before { authorize_user(user) }

    describe "#show" do
      context "with a known widget id" do
        it "is successful and assigns the matching widget component class" do
          get :show, params: {id: "page_counts"}
          expect(response).to be_successful
          expect(assigns(:widget)).to eq(Alchemy::Admin::Dashboard::Widgets::PageCounts)
          expect(assigns(:id)).to eq("page_counts")
        end
      end

      context "with an unknown widget id" do
        it "logs the error and raises a routing error" do
          expect(Alchemy::Logger).to receive(:error).with(/no_such_widget/)
          expect { get :show, params: {id: "no_such_widget"} }
            .to raise_error(ActionController::RoutingError)
        end
      end
    end
  end
end
