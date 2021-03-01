# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Page request caching" do
  let!(:page) { create(:alchemy_page, :public) }

  context "when caching is disabled in app" do
    before do
      Rails.application.config.action_controller.perform_caching = false
    end

    it "sets no-cache header" do
      get "/#{page.urlname}"
      expect(response.headers).to have_key("Cache-Control")
      expect(response.headers["Cache-Control"]).to eq("no-cache")
    end
  end

  context "when caching is enabled in app" do
    before do
      Rails.application.config.action_controller.perform_caching = true
    end

    context "and page should be cached" do
      before do
        allow_any_instance_of(Alchemy::Page).to receive(:cache_page?) { true }
      end

      context "and page is not restricted" do
        before do
          allow_any_instance_of(Alchemy::Page).to receive(:restricted) { false }
        end

        context "for page not having expiration time" do
          before do
            allow_any_instance_of(Alchemy::Page).to receive(:expiration_time) { nil }
          end

          it "sets public cache control header" do
            get "/#{page.urlname}"
            expect(response.headers).to have_key("Cache-Control")
            expect(response.headers["Cache-Control"]).to eq("public, must-revalidate")
          end
        end

        context "for page having expiration time" do
          let!(:public_until) { 10.days.from_now }
          let!(:now) { Time.current }
          let!(:expiration_time) { public_until - now }

          before do
            allow(Time).to receive(:current) { now }
            page.public_version.update(public_until: public_until)
          end

          it "sets max-age cache control header" do
            get "/#{page.urlname}"
            expect(response.headers).to have_key("Cache-Control")
            expect(response.headers["Cache-Control"]).to \
              eq("max-age=#{expiration_time.to_i}, public, must-revalidate")
          end
        end
      end

      context "when page is restricted" do
        before do
          allow_any_instance_of(Alchemy::Page).to receive(:restricted) { true }
        end

        it "sets private cache control header" do
          get "/#{page.urlname}"
          expect(response.headers).to have_key("Cache-Control")
          expect(response.headers["Cache-Control"]).to eq("private, must-revalidate")
        end
      end

      it "sets etag header" do
        get "/#{page.urlname}"
        expect(response.headers).to have_key("ETag")
      end

      it "sets last-modified header" do
        get "/#{page.urlname}"
        expect(response.headers).to have_key("Last-Modified")
        expect(response.headers["Last-Modified"]).to eq(page.published_at.httpdate)
      end
    end

    context "but page should not be cached" do
      before do
        allow_any_instance_of(Alchemy::Page).to receive(:cache_page?) { false }
      end

      it "sets no-cache header" do
        get "/#{page.urlname}"
        expect(response.headers).to have_key("Cache-Control")
        expect(response.headers["Cache-Control"]).to eq("no-cache")
      end

      it "does not set last-modified header" do
        get "/#{page.urlname}"
        expect(response.headers).to_not have_key("Last-Modified")
      end
    end

    context "but a flash message is present" do
      before do
        allow_any_instance_of(ActionDispatch::Flash::FlashHash).to receive(:present?) do
          true
        end
      end

      it "sets no-cache header" do
        get "/#{page.urlname}"
        expect(response.headers).to have_key("Cache-Control")
        expect(response.headers["Cache-Control"]).to eq("no-cache")
      end

      it "does not set last-modified header" do
        get "/#{page.urlname}"
        expect(response.headers).to_not have_key("Last-Modified")
      end
    end

    after do
      Rails.application.config.action_controller.perform_caching = false
    end
  end
end
