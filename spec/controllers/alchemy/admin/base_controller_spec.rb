# frozen_string_literal: true

require "rails_helper"

describe Alchemy::Admin::BaseController do
  describe "#raise_exception?" do
    subject { controller.send(:raise_exception?) }

    context "in test mode" do
      before { expect(Rails.env).to receive(:test?).and_return true }
      it { is_expected.to be_truthy }
    end

    context "not in test mode" do
      before { expect(Rails.env).to receive(:test?).and_return false }
      it { is_expected.to be_falsey }

      context "and in page preview" do
        before { expect(controller).to receive(:is_page_preview?).and_return true }
        it { is_expected.to be_truthy }
      end

      context "and not in page preview" do
        before { expect(controller).to receive(:is_page_preview?).and_return false }
        it { is_expected.to be_falsey }
      end
    end
  end

  describe "#set_translation" do
    context "with unavailable locale in the session" do
      before do
        allow(I18n).to receive(:default_locale) { :es }
        allow(I18n).to receive(:available_locales) { [:es] }
        allow(controller).to receive(:session) { {alchemy_locale: "kl"} }
      end

      it "sets I18n.locale to the default locale" do
        controller.send(:set_translation)
        expect(::I18n.locale).to eq(:es)
      end
    end
  end

  describe "#is_page_preview?" do
    subject { controller.send(:is_page_preview?) }

    it { is_expected.to be_falsey }

    context "is pages controller and show action" do
      before do
        expect(controller).to receive(:controller_path).and_return("alchemy/admin/pages")
        expect(controller).to receive(:action_name).and_return("show")
      end

      it { is_expected.to be_truthy }
    end
  end

  describe "#permission_denied" do
    context "when called with an AccessDenied exception" do
      before do
        allow(controller).to receive(:redirect_to)
        allow(controller).to receive(:render)
      end

      it "redirects to login_path if no user" do
        controller.send(:permission_denied, CanCan::AccessDenied.new)
        expect(controller).to have_received(:redirect_to).with(Alchemy.login_path)
      end

      it "redirects to unauthorized_path for a logged in user" do
        authorize_user(build(:alchemy_dummy_user))
        controller.send(:permission_denied, CanCan::AccessDenied.new)
        expect(controller).to have_received(:redirect_to).with(Alchemy.unauthorized_path)
      end

      context "for a json request" do
        before do
          expect(controller).to receive(:request) do
            double(format: double(json?: true))
          end
        end

        it "returns 'not authorized' message" do
          controller.send(:permission_denied, CanCan::AccessDenied.new)
          expect(controller).to have_received(:render).with(
            json: {message: Alchemy.t("You are not authorized")},
            status: :unauthorized
          )
        end
      end
    end
  end

  describe "#show_error_notice" do
    let(:error) do
      ActiveRecord::ActiveRecordError.new("Database is busy")
    end

    subject do
      controller.send(:show_error_notice, error)
    end

    before do
      allow(controller).to receive(:render)
    end

    context "for a json request" do
      before do
        expect(controller).to receive(:request) do
          double(format: double(json?: true))
        end
      end

      it "returns error message" do
        subject
        expect(controller).to have_received(:render).with(
          json: {message: "Database is busy"},
          status: 500
        )
      end
    end

    context "for a xhr request" do
      before do
        expect(controller).to receive(:request) do
          double(xhr?: true, format: double(json?: false))
        end.twice
      end

      it "renders error notice" do
        subject
        expect(controller).to have_received(:render).with(action: "error_notice")
      end
    end

    context "for a html request" do
      before do
        expect(controller).to receive(:request) do
          double(xhr?: false, format: double(json?: false))
        end.twice
        error.set_backtrace(%(foo))
      end

      it "renders error template" do
        subject
        expect(controller).to have_received(:render).with("500", status: 500)
      end
    end
  end

  context "when current_alchemy_user is present" do
    let!(:page_1) { create(:alchemy_page, name: "Page 1") }
    let!(:page_2) { create(:alchemy_page, name: "Page 2") }
    let(:user) { create(:alchemy_dummy_user, :as_admin) }

    context "and she has locked pages" do
      before do
        allow(controller).to receive(:current_alchemy_user) { user }
        [page_1, page_2].each_with_index do |p, i|
          p.update_columns(locked_at: i.months.ago, locked_by: user.id)
        end
      end

      it "loads locked pages ordered by locked_at date" do
        controller.send(:load_locked_pages)
        expect(assigns(:locked_pages).pluck(:name)).to eq(["Page 2", "Page 1"])
      end
    end
  end

  describe "error responses" do
    controller do
      def index
        raise "Error!"
      end
    end

    before do
      allow_any_instance_of(described_class).to receive(:raise_exception?) { false }
    end

    context "for HTML requests" do
      it "renders 500 template" do
        get :index
        expect(response).to render_template("alchemy/base/500")
      end
    end

    context "for JSON requests" do
      render_views

      it "renders 500 template" do
        get :index, format: :json
        expect(response.media_type).to eq("application/json")
        expect(JSON.parse(response.body)).to eq({"message" => "Error!"})
      end
    end

    describe "#notify_error_tracker" do
      it "does not throw an error if the proc is nil" do
        allow(Alchemy::ErrorTracking).to receive(:notification_handler).and_return(nil)
        expect { controller.send(:notify_error_tracker, StandardError.new) }.not_to raise_error
      end

      it "calls error notification handler" do
        error = StandardError.new
        expect(Alchemy::ErrorTracking.notification_handler).to receive(:call).with(error)
        controller.send(:notify_error_tracker, error)
      end
    end
  end
end
