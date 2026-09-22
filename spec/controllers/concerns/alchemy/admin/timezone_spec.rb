# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::Timezone, type: :controller do
  controller(ActionController::Base) do
    include Alchemy::Admin::Timezone

    def index
      render plain: Time.zone.name
    end

    private

    attr_reader :current_alchemy_user

    def can?(*)
      true
    end
  end

  let(:original_timezone) { Time.zone.name }

  describe "#set_timezone" do
    context "with params[:admin_timezone]" do
      it "sets the timezone from the param" do
        get :index, params: {admin_timezone: "Hawaii"}
        expect(response.body).to eq("Hawaii")
      end

      it "stores the timezone in the session" do
        get :index, params: {admin_timezone: "Hawaii"}
        expect(session[:alchemy_timezone]).to eq("Hawaii")
      end

      it "takes priority over session" do
        get :index, params: {admin_timezone: "Hawaii"}, session: {alchemy_timezone: "Tokyo"}
        expect(response.body).to eq("Hawaii")
      end
    end

    context "with session[:alchemy_timezone]" do
      it "uses the timezone from the session" do
        get :index, session: {alchemy_timezone: "Tokyo"}
        expect(response.body).to eq("Tokyo")
      end
    end

    context "with current_alchemy_user timezone" do
      let(:user) { double("User", timezone: "Berlin") }

      before do
        controller.instance_variable_set(:@current_alchemy_user, user)
      end

      it "uses the user's timezone" do
        get :index
        expect(response.body).to eq("Berlin")
      end

      context "when user does not respond to timezone" do
        let(:user) { double("User") }

        it "falls back to the server default" do
          get :index
          expect(response.body).to eq(original_timezone)
        end
      end

      context "when user's timezone is blank" do
        let(:user) { double("User", timezone: "") }

        it "falls back to the server default" do
          get :index
          expect(response.body).to eq(original_timezone)
        end
      end
    end

    context "with an invalid timezone" do
      it "falls back to the server default" do
        get :index, params: {admin_timezone: "Nonexistent/Zone"}
        expect(response.body).to eq(original_timezone)
      end
    end

    context "with no timezone set anywhere" do
      it "uses the server default timezone" do
        get :index
        expect(response.body).to eq(original_timezone)
      end

      it "stores the server default in session" do
        get :index
        expect(session[:alchemy_timezone]).to eq(original_timezone)
      end
    end

    it "restores the original timezone after the request" do
      original = Time.zone.name
      get :index, params: {admin_timezone: "Hawaii"}
      expect(Time.zone.name).to eq(original)
    end

    context "when user cannot edit content" do
      controller(ActionController::Base) do
        include Alchemy::Admin::Timezone

        def index
          render plain: Time.zone.name
        end

        private

        def can?(*)
          false
        end
      end

      it "does not set the timezone" do
        get :index, params: {admin_timezone: "Hawaii"}
        expect(response.body).to eq(original_timezone)
      end
    end
  end
end
