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
            locked: [],
          ),
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
            expect(Alchemy.user_class).to receive(:logged_in).and_return([another_user])
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

    describe "#update_check" do
      before do
        WebMock.enable!
      end

      context "requesting rubygems.org" do
        before do
          stub_request(:get, "https://rubygems.org/api/v1/versions/alchemy_cms.json").to_return(
            status: 200, body: '[{"number": "3.0.0.alpha"}, {"number": "2.6.0"}, {"number": "2.5.1"}]',
          )
        end

        context "if current Alchemy version equals the latest released version or it is newer" do
          before do
            allow(Alchemy).to receive(:version).and_return("2.6.2")
          end

          it "should render 'false'" do
            get :update_check
            expect(response.code).to eq("200")
            expect(response.body).to eq("false")
          end
        end

        context "if current Alchemy version is older than latest released version" do
          before do
            allow(Alchemy).to receive(:version).and_return("2.5.0")
          end

          it "should render 'true'" do
            get :update_check
            expect(response.code).to eq("200")
            expect(response.body).to eq("true")
          end
        end
      end

      context "if rubygems.org is unavailable" do
        before do
          stub_request(:get, "https://rubygems.org/api/v1/versions/alchemy_cms.json").to_return(status: 503)
          stub_request(:get, "https://api.github.com/repos/AlchemyCMS/alchemy_cms/tags").to_return(
            status: 200, body: '[{"name": "v2.6.0"}, {"name": "v2.5.0"}]',
          )
          allow(Alchemy).to receive(:version).and_return("2.6.2")
        end

        it "should request github.com" do
          get :update_check
          expect(response.code).to eq("200")
          expect(response.body).to eq("false")
        end
      end

      context "rubygems.org and github.com are unavailable" do
        before do
          stub_request(:get, /rubygems|github/).to_return(status: 503)
        end

        it "should have status code 503" do
          get :update_check
          expect(response.code).to eq("503")
        end
      end

      after do
        WebMock.disable!
      end
    end
  end
end
