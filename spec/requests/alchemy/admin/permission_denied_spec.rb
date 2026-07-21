# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Permission denied in the admin" do
  let(:picture) { create(:alchemy_picture) }

  # An author may not manage pictures, but may access the dashboard.
  before { authorize_user(:as_author) }

  context "with a json request" do
    subject!(:request) do
      delete alchemy.admin_picture_path(picture), headers: {
        "Accept" => "application/json"
      }
    end

    it "responds with 403 and the message" do
      expect(response).to be_forbidden
      expect(JSON.parse(response.body)).to eq(
        "message" => Alchemy.t("You are not authorized")
      )
    end
  end

  context "with an xhr request" do
    subject!(:request) do
      delete alchemy.admin_picture_path(picture), headers: {
        "X-Requested-With" => "XMLHttpRequest",
        "Accept" => "text/vnd.turbo-stream.html"
      }
    end

    it "responds with 403" do
      expect(response).to be_forbidden
    end

    it "responds with json" do
      expect(response.media_type).to eq("application/json")
    end

    it "returns the message" do
      expect(JSON.parse(response.body)).to eq(
        "message" => Alchemy.t("You are not authorized")
      )
    end

    it "does not keep the flash for the next request" do
      get alchemy.admin_dashboard_path
      expect(response.body).to_not include(Alchemy.t("You are not authorized"))
    end
  end

  context "with a turbo frame request" do
    subject!(:request) do
      delete alchemy.admin_picture_path(picture), headers: {
        "Turbo-Frame" => "alchemy_dialog_frame"
      }
    end

    it "renders the 403 page into the frame" do
      expect(response).to be_forbidden
      expect(response.body).to include(Alchemy.t("You are not authorized"))
    end
  end

  context "with a regular request" do
    subject!(:request) { delete alchemy.admin_picture_path(picture) }

    it "redirects to the dashboard" do
      expect(response).to redirect_to(alchemy.admin_dashboard_path)
    end
  end

  context "as a guest whose session expired" do
    before { authorize_user(nil) }

    context "with an xhr request" do
      subject!(:request) do
        delete alchemy.admin_picture_path(picture), headers: {
          "X-Requested-With" => "XMLHttpRequest",
          "Accept" => "application/json"
        }
      end

      it "responds with 401" do
        expect(response).to be_unauthorized
      end

      it "tells the client where to log in" do
        expect(JSON.parse(response.body)).to eq(
          "message" => Alchemy.t("Please log in"),
          "redirect_url" => Alchemy.config.login_path
        )
      end

      it "carries a flash over, so the login page says why" do
        expect(flash[:info]).to eq(Alchemy.t("Please log in"))
      end
    end

    context "with a turbo frame request" do
      subject!(:request) do
        get alchemy.admin_pictures_path, headers: {
          "Turbo-Frame" => Alchemy::Admin::DIALOG_FRAME_ID
        }
      end

      it "responds with a turbo stream that leaves the frame for the login page" do
        expect(response).to be_unauthorized
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
        expect(response.body).to include(%(action="dialog_visit"))
        expect(response.body).to include(%(url="#{Alchemy.config.login_path}"))
      end

      it "carries a flash over, so the login page says why" do
        expect(flash[:info]).to eq(Alchemy.t("Please log in"))
      end
    end

    context "with a regular request" do
      subject!(:request) { get alchemy.admin_pictures_path }

      it "redirects to the login page" do
        expect(response).to redirect_to(Alchemy.config.login_path)
      end
    end

    context "with a custom login path configured" do
      before do
        allow(Alchemy.config).to receive(:login_path).and_return("/my/login")
      end

      it "sends json clients to it" do
        delete alchemy.admin_picture_path(picture), headers: {
          "X-Requested-With" => "XMLHttpRequest",
          "Accept" => "application/json"
        }
        expect(JSON.parse(response.body)["redirect_url"]).to eq("/my/login")
      end

      it "sends dialogs to it" do
        get alchemy.admin_pictures_path, headers: {
          "Turbo-Frame" => Alchemy::Admin::DIALOG_FRAME_ID
        }
        expect(response.body).to include(%(url="/my/login"))
      end
    end
  end

  context "in another admin locale" do
    before do
      I18n.backend.store_translations(:kl, alchemy: {
        "Please log in": "tlhIngan Hol lujat!",
        "You are not authorized": "chaw' Hutlh!"
      })
      allow(Alchemy::I18n).to receive(:available_locales) { [:en, :kl] }
    end

    after { I18n.backend.reload! }

    subject(:message) do
      delete alchemy.admin_picture_path(picture, admin_locale: "kl"), headers: {
        "X-Requested-With" => "XMLHttpRequest",
        "Accept" => "application/json"
      }
      JSON.parse(response.body)["message"]
    end

    it "translates the message for a denied user" do
      expect(message).to eq("chaw' Hutlh!")
    end

    it "translates the message for a guest" do
      authorize_user(nil)
      expect(message).to eq("tlhIngan Hol lujat!")
    end
  end
end
