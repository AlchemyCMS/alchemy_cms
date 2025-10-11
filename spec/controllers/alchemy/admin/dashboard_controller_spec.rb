# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Admin::DashboardController do
    routes { Alchemy::Engine.routes }

    let(:user) { build_stubbed(:alchemy_dummy_user, :as_admin) }

    before { authorize_user(user) }

    describe "#index" do
      before do
        allow(Page).to receive(:from_current_site).and_return(
          double(
            all_last_edited_from: [],
            locked_by: [],
            locked: []
          )
        )
      end

      it "assigns @last_edited_pages" do
        get :index
        expect(assigns(:last_edited_pages)).to eq([])
      end

      it "assigns @all_locked_pages" do
        get :index
        expect(assigns(:all_locked_pages)).to eq([])
      end

      context "with user class having logged_in scope" do
        context "with other users online" do
          let(:another_user) { mock_model("DummyUser") }

          before do
            expect(Alchemy.config.user_class).to receive(:logged_in).and_return([another_user])
          end

          it "assigns @online_users" do
            get :index
            expect(assigns(:online_users)).to eq([another_user])
          end
        end

        context "without other users online" do
          it "does not assign @online_users" do
            get :index
            expect(assigns(:online_users)).to eq([])
          end
        end
      end

      context "user having signed in before" do
        before do
          expect(user).to receive(:sign_in_count).and_return(5)
          expect(user).to receive(:last_sign_in_at).and_return(Time.current)
        end

        it "assigns @first_time" do
          get :index
          expect(assigns(:first_time)).to eq(false)
        end
      end

      it "assigns @sites" do
        get :index
        expect(assigns(:sites)).to eq(Site.all)
      end
    end

    describe "#info" do
      it "assigns @alchemy_version with the current Alchemy version" do
        get :info
        expect(assigns(:alchemy_version)).to eq(Alchemy.version)
      end
    end
  end
end
