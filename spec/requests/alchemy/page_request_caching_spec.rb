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
          stub_alchemy_config(:cache_pages, false)
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

      context "and public version is present" do
        let(:jan_first) { Time.new(2020, 1, 1) }

        before do
          allow_any_instance_of(Alchemy::Page).to receive(:last_modified_at) { jan_first }
        end

        it "sets last-modified header" do
          get "/#{page.urlname}"
          expect(response.headers).to have_key("Last-Modified")
          expect(response.headers["Last-Modified"]).to eq(jan_first.httpdate)
        end
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
