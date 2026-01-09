# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe BaseController do
    describe "#set_locale" do
      context "with Current.language set" do
        let(:language) { create(:alchemy_language, :klingon) }

        before { Alchemy::Current.language = language }

        it "sets the ::I18n.locale to current language code" do
          controller.send(:set_locale)
          expect(::I18n.locale).to eq(language.code.to_sym)
        end
      end

      context "without Current.language set" do
        before { Alchemy::Current.language = nil }

        it "does not set the ::I18n.locale" do
          expect {
            controller.send(:set_locale)
          }.not_to change { ::I18n.locale }
        end
      end
    end

    describe "#configuration" do
      it "returns certain configuration options" do
        Deprecation.silenced do
          allow(Alchemy.config).to receive(:some_option).and_return(true)
          expect(controller.configuration(:some_option)).to eq(true)
        end
      end
    end

    describe "#permission_denied" do
      subject(:permission_denied) do
        controller.send(:permission_denied, CanCan::AccessDenied.new)
      end

      context "when called with an AccessDenied exception" do
        before do
          allow(controller).to receive(:redirect_to)
        end

        it "redirects to config.login_path if no user" do
          permission_denied
          expect(controller).to have_received(:redirect_to).with(Alchemy.config.login_path)
        end

        context "for a logged in member user" do
          before do
            authorize_user build(:alchemy_dummy_user)
          end

          it "redirects to config.unauthorized_path" do
            permission_denied
            expect(controller).to have_received(:redirect_to).with(Alchemy.config.unauthorized_path)
          end
        end

        context "for a logged in author user" do
          before do
            authorize_user build(:alchemy_dummy_user, :as_author)
          end

          it "redirects to dashboard path" do
            permission_denied
            expect(controller).to have_received(:redirect_to).with(admin_dashboard_path)
          end

          context "with a turbo frame request" do
            before do
              allow(controller).to receive(:turbo_frame_request?).and_return(true)
            end

            controller do
              def index
                permission_denied
              end
            end

            it "renders 403 page" do
              get :index
              expect(response).to be_forbidden
              expect(response).to render_template("alchemy/base/403")
            end
          end
        end
      end
    end

    describe "#multi_language?" do
      subject { controller.multi_language? }

      context "if no language exists" do
        it { is_expected.to be(false) }
      end

      context "if less than two published languages exists" do
        let!(:language) { create(:alchemy_language) }
        it { is_expected.to be(false) }
      end

      context "if more than one published language exists" do
        let!(:language) { create(:alchemy_language) }
        let!(:language_2) do
          create(:alchemy_language, :klingon)
        end

        it { is_expected.to be(true) }
      end

      context "for multiple sites" do
        let!(:default_site) { create(:alchemy_site, :default) }

        let!(:site_2) do
          create(:alchemy_site, host: "another-host.com")
        end

        let!(:site_2_language_2) do
          create(:alchemy_language, :klingon, site: site_2)
        end

        it "only is true for current site" do
          is_expected.to be(false)
        end
      end
    end

    describe "#prefix_locale?" do
      subject(:prefix_locale?) { controller.prefix_locale? }

      context "if multi_language? is true" do
        let!(:language) { create(:alchemy_language) }
        let!(:language_2) do
          create(:alchemy_language, :klingon)
        end

        context "and current language is not the default locale" do
          before do
            allow(Alchemy::Current).to receive(:language) { double(code: "kl") }
            allow(::I18n).to receive(:default_locale) { :de }
          end

          it { expect(prefix_locale?).to be(true) }
        end

        context "and current language is the default locale" do
          before do
            allow(Alchemy::Current).to receive(:language) { double(code: "de") }
            allow(::I18n).to receive(:default_locale) { :de }
          end

          it { expect(prefix_locale?).to be(false) }
        end

        context "and passed in locale is not the default locale" do
          subject(:prefix_locale?) { controller.prefix_locale?("en") }

          before do
            allow(::I18n).to receive(:default_locale) { :de }
          end

          it { expect(prefix_locale?).to be(true) }
        end

        context "and passed in locale is the default locale" do
          subject(:prefix_locale?) { controller.prefix_locale?("de") }

          before do
            allow(::I18n).to receive(:default_locale) { :de }
          end

          it { expect(prefix_locale?).to be(false) }
        end
      end

      context "if multi_language? is false" do
        let!(:language) { create(:alchemy_language) }

        it { expect(prefix_locale?).to be(false) }
      end
    end
  end
end
