# frozen_string_literal: true

require "ostruct"
require "rails_helper"

module Alchemy
  describe PagesController do
    routes { Alchemy::Engine.routes }

    let(:default_language) { create(:alchemy_language) }

    let(:default_language_root) do
      create(:alchemy_page, :language_root, language: default_language, name: "Home")
    end

    let(:page) do
      create :alchemy_page, :public,
        parent_id: default_language_root.id,
        page_layout: "news",
        name: "News",
        urlname: "news",
        language: default_language,
        autogenerate_elements: true
    end

    before do
      allow(controller).to receive(:signup_required?).and_return(false)
    end

    describe "#index" do
      context "without a site or language present" do
        it "returns a 404" do
          expect { get(:index) }.to raise_exception(
            ActionController::RoutingError,
            'Alchemy::Page not found "/"',
          )
        end
      end

      context "with site and language root present" do
        before do
          default_language_root
        end

        it "renders :show template" do
          expect(get(:index)).to render_template(:show)
        end

        context "requesting nothing" do
          it "loads default language root page" do
            get :index
            expect(assigns(:page)).to eq(default_language_root)
          end

          it "sets @root_page to default language root" do
            get :index
            expect(assigns(:root_page)).to eq(default_language_root)
          end

          context "and the root page is not public" do
            let(:default_language_root) do
              create(:alchemy_page, :language_root, public_on: nil, language: default_language, name: "Home")
            end

            it "raises routing error (404)" do
              expect {
                get :index
              }.to raise_error(ActionController::RoutingError)
            end

            context "when a page layout callback is set" do
              before do
                ApplicationController.extend Alchemy::OnPageLayout
                ApplicationController.class_eval do
                  on_page_layout("index") { "do something" }
                end
              end

              it 'raises routing error (404) and no "undefined method for nil" error' do
                expect {
                  get :index
                }.to raise_error(ActionController::RoutingError)
              end
            end
          end
        end

        context "requesting non default locale" do
          let!(:klingon) do
            create(:alchemy_language, :klingon, default: false)
          end

          let!(:start_page) do
            create :alchemy_page, :language_root,
              language: klingon,
              name: "Start Page"
          end

          before do
            allow(::I18n).to receive(:default_locale) { "de" }
          end

          it "loads the root page of that language" do
            get :index, params: { locale: "kl" }
            expect(assigns(:page)).to eq(start_page)
          end

          it "sets @root_page to root page of that language" do
            get :index, params: { locale: "kl" }
            expect(assigns(:root_page)).to eq(start_page)
          end
        end
      end

      describe "requesting a not yet public page" do
        let(:not_yet_public) do
          create :alchemy_page,
            parent: default_language_root,
            public_on: 1.day.from_now
        end

        it "renders 404" do
          expect {
            get :show, params: { urlname: not_yet_public.urlname }
          }.to raise_error(ActionController::RoutingError)
        end
      end

      describe "requesting a no longer public page" do
        let(:no_longer_public) do
          create :alchemy_page, :public,
            parent: default_language_root,
            public_on: 2.days.ago,
            public_until: 1.day.ago
        end

        it "renders 404" do
          expect {
            get :show, params: { urlname: no_longer_public.urlname }
          }.to raise_error(ActionController::RoutingError)
        end
      end

      describe "requesting a still public page" do
        let(:still_public_page) do
          create :alchemy_page,
            parent: default_language_root,
            public_on: 2.days.ago,
            public_until: 1.day.from_now
        end

        it "renders page" do
          get :show, params: { urlname: still_public_page.urlname }
          expect(response).to be_successful
        end
      end

      describe "requesting a page without time limit" do
        let(:still_public_page) do
          create :alchemy_page,
            parent: default_language_root,
            public_on: 2.days.ago,
            public_until: nil
        end

        it "renders page" do
          get :show, params: { urlname: still_public_page.urlname }
          expect(response).to be_successful
        end
      end

      context "requested for a page containing a feed" do
        render_views

        it "should render a rss feed" do
          get :show, params: { urlname: page.urlname, format: :rss }
          expect(response.media_type).to eq("application/rss+xml")
        end

        it "should include content" do
          page.elements.first.content_by_name("news_headline").essence.update_columns(body: "Peters Petshop")
          get :show, params: { urlname: "news", format: :rss }
          expect(response.body).to match /Peters Petshop/
        end
      end

      context "requested for a page that does not contain a feed" do
        it "should render xml 404 error" do
          get :show, params: { urlname: default_language_root.urlname, format: :rss }
          expect(response.status).to eq(404)
        end
      end

      describe "Layout rendering" do
        context "with ajax request" do
          it "should not render a layout" do
            get :show, params: { urlname: page.urlname }, xhr: true
            expect(response).to render_template(:show)
            expect(response).not_to render_template(layout: "application")
          end
        end
      end

      describe "url nesting" do
        render_views

        let(:catalog) { create(:alchemy_page, :public, name: "Catalog", urlname: "catalog", parent: default_language_root, language: default_language) }
        let(:products) { create(:alchemy_page, :public, name: "Products", urlname: "products", parent: catalog, language: default_language) }
        let(:product) { create(:alchemy_page, :public, name: "Screwdriver", urlname: "screwdriver", parent: products, language: default_language, autogenerate_elements: true) }

        before do
          allow(Alchemy.user_class).to receive(:admins).and_return(OpenStruct.new(count: 1))
          product.elements.find_by_name("article").contents.essence_texts.first.essence.update_column(:body, "screwdriver")
        end

        context "with correct levelnames in params" do
          it "should show the requested page" do
            get :show, params: { urlname: "catalog/products/screwdriver" }
            expect(response.status).to eq(200)
            expect(response.body).to have_content("screwdriver")
          end
        end

        context "with incorrect levelnames in params" do
          it "should render a 404 page" do
            expect {
              get :show, params: { urlname: "catalog/faqs/screwdriver" }
            }.to raise_error(ActionController::RoutingError)
          end
        end
      end

      context "when a non-existent page is requested" do
        it "should rescue a RoutingError with rendering a 404 page." do
          expect {
            get :show, params: { urlname: "doesntexist" }
          }.to raise_error(ActionController::RoutingError)
        end
      end

      describe "while redirecting" do
        context "not in multi language mode" do
          before do
            allow_any_instance_of(PagesController).to receive(:multi_language?).and_return(false)
          end

          context "with no lang parameter present" do
            it "should store defaults language id in the session." do
              get :show, params: { urlname: page.urlname }
              expect(controller.session[:alchemy_language_id]).to eq(Language.default.id)
            end

            it "should store default language as class var." do
              get :show, params: { urlname: page.urlname }
              expect(Language.current).to eq(Language.default)
            end
          end
        end
      end

      context "in an environment with multiple languages" do
        let(:klingon) { create(:alchemy_language, :klingon) }

        context "having two pages with the same url names in different languages" do
          render_views

          let!(:klingon_page) { create(:alchemy_page, :public, language: klingon, name: "same-name", autogenerate_elements: true) }
          let!(:english_page) { create(:alchemy_page, :public, language: default_language, name: "same-name") }

          before do
            # Set a text in an essence rendered on the page so we can match against that
            klingon_page.essence_texts.first.update_column(:body, "klingon page")
          end

          it "renders the page related to its language" do
            get :show, params: { urlname: "same-name", locale: klingon_page.language_code }
            expect(response.body).to have_content("klingon page")
          end
        end
      end

      describe "#page_etag" do
        subject { controller.send(:page_etag) }

        before do
          expect(page).to receive(:cache_key).and_return("aaa")
          controller.instance_variable_set("@page", page)
        end

        it "returns the etag for response headers" do
          expect(subject).to eq("aaa")
        end

        context "with user logged in" do
          before do
            authorize_user(mock_model(Alchemy.user_class, cache_key: "bbb"))
          end

          it "returns another etag for response headers" do
            expect(subject).to eq("aaabbb")
          end
        end
      end
    end
  end
end
