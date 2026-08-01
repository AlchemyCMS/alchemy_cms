# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Admin::DashboardController do
    routes { Alchemy::Engine.routes }

    let(:user) { build_stubbed(:alchemy_dummy_user, :as_admin) }

    before { authorize_user(user) }

    describe "#index" do
      it "renders the dashboard" do
        get :index
        expect(response).to render_template("alchemy/admin/dashboard/index")
      end
    end

    describe "#info" do
      it "is deprecated" do
        expect(Alchemy::Deprecation).to receive(:warn)
        get :info
      end
    end

    describe "#license" do
      it "reads the LICENSE file" do
        get :license
        expect(assigns(:license)).to include("Redistribution and use in source and binary forms")
      end
    end
  end
end
