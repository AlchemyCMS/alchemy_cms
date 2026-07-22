# frozen_string_literal: true

require "rails_helper"

RSpec.describe "XML sitemap caching" do
  let!(:page) { create(:alchemy_page, :public, sitemap: true) }

  let(:max_age) { Alchemy.config.sitemap.max_age }

  # The test environment uses a :null_store, which would make every
  # Rails.cache.fetch a miss and render the cache assertions meaningless.
  let(:cache_store) { ActiveSupport::Cache::MemoryStore.new }

  before { allow(Rails).to receive(:cache).and_return(cache_store) }

  # Counts template renders so we can tell a cache hit from a re-render.
  def rendered_templates
    templates = []
    subscriber = ->(*, payload) { templates << payload[:identifier] }
    ActiveSupport::Notifications.subscribed(subscriber, "render_template.action_view") do
      yield
    end
    templates
  end

  context "when caching is enabled" do
    before { ActionController::Base.perform_caching = true }
    after { ActionController::Base.perform_caching = false }

    it "sets a public cache-control header with the configured max-age" do
      get "/sitemap.xml"

      expect(response).to have_http_status(:ok)
      expect(response.headers["Cache-Control"]).to include("max-age=#{max_age}")
      expect(response.headers["Cache-Control"]).to include("public")
    end

    it "sets an ETag" do
      get "/sitemap.xml"
      expect(response.headers["ETag"]).to be_present
    end

    it "renders valid xml on a cache miss and on a cache hit" do
      2.times do
        get "/sitemap.xml"

        expect(response.media_type).to eq("application/xml")
        xml_doc = Nokogiri::XML(response.body)
        expect(xml_doc.namespaces["xmlns"]).to eq("http://www.sitemaps.org/schemas/sitemap/0.9")
        expect(xml_doc.css("urlset url loc").length).to eq(2)
      end
    end

    it "responds with 304 when revalidating with a matching ETag" do
      get "/sitemap.xml"
      etag = response.headers["ETag"]

      get "/sitemap.xml", headers: {"If-None-Match" => etag}

      expect(response).to have_http_status(:not_modified)
      expect(response.body).to be_empty
    end

    it "renders the sitemap only once for repeated requests" do
      templates = rendered_templates do
        get "/sitemap.xml"
        get "/sitemap.xml"
      end

      expect(templates.grep(/sitemap/).length).to eq(1)
    end

    it "responds with 304 without rendering the sitemap" do
      get "/sitemap.xml"
      etag = response.headers["ETag"]

      templates = rendered_templates do
        get "/sitemap.xml", headers: {"If-None-Match" => etag}
      end

      expect(templates.grep(/sitemap/)).to be_empty
    end

    it "invalidates the cache when a page is updated" do
      get "/sitemap.xml"
      etag = response.headers["ETag"]

      travel 1.second do
        page.touch
        get "/sitemap.xml", headers: {"If-None-Match" => etag}
      end

      expect(response).to have_http_status(:ok)
    end

    # Regression test for the revalidation trap: an ETag derived only from the
    # page contents would never change, so a scheduled page could never enter
    # the sitemap and clients would revalidate into a 304 forever.
    it "invalidates the cache once max_age has elapsed" do
      get "/sitemap.xml"
      etag = response.headers["ETag"]

      travel(max_age + 10) do
        get "/sitemap.xml", headers: {"If-None-Match" => etag}
      end

      expect(response).to have_http_status(:ok)
    end

    it "picks up a page that was scheduled to be published" do
      scheduled = create(:alchemy_page, sitemap: true)
      scheduled.versions.create!(public_on: 30.minutes.from_now)

      get "/sitemap.xml"
      expect(response.body).to_not include(scheduled.urlname)

      travel(max_age + 10) do
        get "/sitemap.xml"
        expect(response.body).to include(scheduled.urlname)
      end
    end

    # Alchemy::Site.find_for_host resolves a site from its host or its aliases,
    # so one site can be served under several hostnames. The urls in the body
    # are absolute, so the cache must not be shared between them.
    it "does not serve one host's urls to another host" do
      get "/sitemap.xml", headers: {"HOST" => "example.com"}
      expect(response.body).to include("http://example.com/")

      get "/sitemap.xml", headers: {"HOST" => "www.example.org"}
      expect(response.body).to include("http://www.example.org/")
      expect(response.body).to_not include("http://example.com/")
    end

    # The sitemap is not a page, and sitemap.max_age is its own switch.
    context "with page caching turned off" do
      before { stub_alchemy_config(cache_pages: false) }

      it "still caches the sitemap" do
        templates = rendered_templates do
          get "/sitemap.xml"
          get "/sitemap.xml"
        end

        expect(templates.grep(/sitemap/).length).to eq(1)
      end
    end

    context "with an empty sitemap" do
      before { Alchemy::Page.update_all(sitemap: false) }

      it "renders a valid empty urlset" do
        get "/sitemap.xml"

        expect(response).to have_http_status(:ok)
        xml_doc = Nokogiri::XML(response.body)
        expect(xml_doc.namespaces["xmlns"]).to eq("http://www.sitemaps.org/schemas/sitemap/0.9")
        expect(xml_doc.css("urlset url")).to be_empty
      end
    end
  end

  context "when max_age is zero" do
    before do
      ActionController::Base.perform_caching = true
      allow(Alchemy.config.sitemap).to receive(:max_age).and_return(0)
    end

    after { ActionController::Base.perform_caching = false }

    it "renders the sitemap uncached" do
      get "/sitemap.xml"

      expect(response).to have_http_status(:ok)
      expect(response.headers["Cache-Control"]).to_not include("public")
      expect(Nokogiri::XML(response.body).css("urlset url loc").length).to eq(2)
    end
  end

  context "when caching is disabled" do
    before { ActionController::Base.perform_caching = false }

    it "does not set a public cache-control header" do
      get "/sitemap.xml"

      expect(response).to have_http_status(:ok)
      expect(response.headers["Cache-Control"]).to_not include("public")
    end

    it "renders the sitemap on every request" do
      templates = rendered_templates do
        get "/sitemap.xml"
        get "/sitemap.xml"
      end

      expect(templates.grep(/sitemap/).length).to eq(2)
    end

    it "still renders a valid sitemap" do
      get "/sitemap.xml"

      expect(response.media_type).to eq("application/xml")
      xml_doc = Nokogiri::XML(response.body)
      expect(xml_doc.css("urlset url loc").length).to eq(2)
    end
  end
end
