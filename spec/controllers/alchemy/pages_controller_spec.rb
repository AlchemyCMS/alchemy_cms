# frozen_string_literal: true

require "ostruct"
require "rails_helper"

module Alchemy
  describe PagesController do
    routes { Alchemy::Engine.routes }

    let(:default_language) { create(:alchemy_language) }

    let(:default_language_root) do
      create(:alchemy_page, :public, :language_root, language: default_language, name: "Home")
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
        it "returns a no_index page" do
          expect(get(:index)).to render_template("alchemy/no_index")
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

          context "and the root page is not public" do
            let(:default_language_root) do
              create(:alchemy_page, :language_root, public_on: nil, language: default_language, name: "Home")
            end

            it "returns a no_index page" do
              expect(get(:index)).to render_template("alchemy/no_index")
            end

            context "when a page layout callback is set" do
              before do
                ApplicationController.extend Alchemy::OnPageLayout
                ApplicationController.class_eval do
                  on_page_layout("index") { "do something" }
                end
              end

              it 'does not raise "undefined method for nil" error' do
                expect { get :index }.to_not raise_error
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
            get :index, params: {locale: "kl"}
            expect(assigns(:page)).to eq(start_page)
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
            get :show, params: {urlname: not_yet_public.urlname}
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
            get :show, params: {urlname: no_longer_public.urlname}
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
          get :show, params: {urlname: still_public_page.urlname}
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
          get :show, params: {urlname: still_public_page.urlname}
          expect(response).to be_successful
        end
      end

      describe "Layout rendering" do
        context "with ajax request" do
          it "should not render a layout" do
            get :show, params: {urlname: page.urlname}, xhr: true
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
          product.elements.find_by(name: "article").ingredients.texts.first.update_column(:value, "screwdriver")
        end

        context "with correct levelnames in params" do
          it "should show the requested page" do
            get :show, params: {urlname: "catalog/products/screwdriver"}
            expect(response.status).to eq(200)
            expect(response.body).to have_content("screwdriver")
          end
        end

        context "with incorrect levelnames in params" do
          it "should render a 404 page" do
            expect {
              get :show, params: {urlname: "catalog/faqs/screwdriver"}
            }.to raise_error(ActionController::RoutingError)
          end
        end
      end

      context "when a non-existent page is requested" do
        it "should rescue a RoutingError with rendering a 404 page." do
          expect {
            get :show, params: {urlname: "doesntexist"}
          }.to raise_error(ActionController::RoutingError)
        end
      end

      describe "while redirecting" do
        context "not in multi language mode" do
          before do
            allow_any_instance_of(PagesController).to receive(:multi_language?).and_return(false)
          end

          context "with no lang parameter present" do
            it "should store default language as class var." do
              get :show, params: {urlname: page.urlname}
              expect(Current.language).to eq(Language.default)
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
            # Set a text in an ingredient rendered on the page so we can match against that
            klingon_page.ingredients.texts.first.update_column(:value, "klingon page")
          end

          it "renders the page related to its language" do
            get :show, params: {urlname: "same-name", locale: klingon_page.language_code}
            expect(response.body).to have_content("klingon page")
          end
        end
      end

      describe "#page_etag" do
        subject { controller.send(:page_etag) }

        before do
          controller.instance_variable_set(:@page, page)
        end

        it "returns the etag for response headers" do
          expect(subject).to include(page)
        end

        context "with user logged in" do
          before do
            authorize_user(mock_model(Alchemy.user_class, cache_key_with_version: "bbb"))
          end

          it "returns another etag for response headers" do
            expect(subject).to include(an_instance_of(Alchemy.user_class))
          end
        end
      end
    end
  end
end
