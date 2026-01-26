# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Page request caching" do
  let(:page) { create(:alchemy_page, :public) }

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

        context "for page not having expiration time configured" do
          it "sets public cache control header" do
            get "/#{page.urlname}"
            expect(response.headers).to have_key("Cache-Control")
            expect(response.headers["Cache-Control"]).to eq("max-age=60, public, must-revalidate")
          end
        end

        context "when stale_while_revalidate is enabled" do
          before do
            allow(Alchemy.config).to receive(:page_cache) do
              double(stale_while_revalidate: 3600, max_age: 600)
            end
          end

          it "sets cache-control header stale-while-revalidate" do
            get "/#{page.urlname}"
            expect(response.headers).to have_key("Cache-Control")
            expect(response.headers["Cache-Control"]).to \
              eq("max-age=60, public, stale-while-revalidate=3600")
          end
        end

        context "for page having expiration time configured" do
          before do
            allow_any_instance_of(Alchemy::Page).to receive(:expiration_time) { 3600 }
          end

          it "sets max-age cache control header" do
            get "/#{page.urlname}"
            expect(response.headers).to have_key("Cache-Control")
            expect(response.headers["Cache-Control"]).to \
              eq("max-age=3600, public, must-revalidate")
          end
        end
      end

      context "when page must not be cached" do
        before do
          allow_any_instance_of(Alchemy::Page).to receive(:cache_page?) { false }
        end

        it "sets no-cache cache-control header" do
          get "/#{page.urlname}"
          expect(response.headers).to have_key("Cache-Control")
          expect(response.headers["Cache-Control"]).to eq("no-cache")
        end
      end

      context "when caching is deactivated in the Alchemy config" do
        before do
          stub_alchemy_config(cache_pages: false)
        end

        it "returns false" do
          get "/#{page.urlname}"
          expect(response.headers["cache-control"]).to eq("no-cache")
        end
      end

      it "sets etag header" do
        get "/#{page.urlname}"
        expect(response.headers).to have_key("ETag")
      end

      context "with scheduled element becoming visible" do
        let!(:scheduled_element) do
          create(:alchemy_element, page_version: page.public_version, public_on: 1.hour.from_now)
        end

        it "changes the etag when element becomes visible" do
          get "/#{page.urlname}"
          etag_before = response.headers["ETag"]

          travel 2.hours do
            get "/#{page.urlname}"
            etag_after = response.headers["ETag"]
            expect(etag_after).not_to eq(etag_before)
          end
        end

        it "returns 200 instead of 304 after element becomes visible" do
          get "/#{page.urlname}"
          etag = response.headers["ETag"]

          travel 2.hours do
            get "/#{page.urlname}", headers: {"If-None-Match" => etag}
            expect(response.status).to eq(200)
          end
        end
      end

      it "does not set last-modified header" do
        get "/#{page.urlname}"
        expect(response.headers).to_not have_key("Last-Modified")
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
