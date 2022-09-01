# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Api::PagesController do
    routes { Alchemy::Engine.routes }

    describe "#index" do
      let(:result) { JSON.parse(response.body) }

      context "without a default language present" do
        it "returns JSON" do
          get :index, params: { format: :json }
          expect(result["pages"]).to eq([])
        end
      end

      context "with a default language and a page present" do
        let!(:default_language) { create(:alchemy_language, :english, default: true) }
        let!(:page) { create(:alchemy_page, :public, language: default_language) }

        it "returns JSON" do
          get :index, params: { format: :json }

          expect(response.status).to eq(200)
          expect(response.media_type).to eq("application/json")
          expect(result).to have_key("pages")
        end

        it "returns all public pages" do
          get :index, params: { format: :json }

          expect(result["pages"].size).to eq(2)
        end

        context "as author" do
          before do
            authorize_user(build(:alchemy_dummy_user, :as_author))
          end

          it "returns all pages" do
            get :index, params: { format: :json }

            expect(result["pages"].size).to eq(Alchemy::Page.count)
          end
        end

        it "includes meta data" do
          get :index, params: { format: :json }

          expect(result["pages"].size).to eq(2)
          expect(result["meta"]["page"]).to be_nil
          expect(result["meta"]["per_page"]).to eq(2)
          expect(result["meta"]["total_count"]).to eq(2)
        end

        context "with page param given" do
          let!(:page1) { create(:alchemy_page, language: default_language) }
          let!(:page2) { create(:alchemy_page, language: default_language) }

          before do
            expect(Kaminari.config).to receive(:default_per_page).at_least(:once) { 1 }
          end

          it "returns paginated result" do
            get :index, params: { page: 2, format: :json }

            expect(result["pages"].size).to eq(1)
            expect(result["meta"]["page"]).to eq(2)
            expect(result["meta"]["per_page"]).to eq(1)
            expect(result["meta"]["total_count"]).to eq(2)
          end
        end

        context "with ransack query param given" do
          it "returns filtered result" do
            get :index, params: { q: { name_eq: page.name }, format: :json }

            expect(result["pages"].size).to eq(1)
          end
        end

        context "with multiple sites" do
          let(:site_2) { create(:alchemy_site) }
          let(:language_2) { create(:alchemy_language, site: site_2) }
          let!(:site_2_page) { create(:alchemy_page, :public, language: language_2) }
          let!(:unpublished_page) { create(:alchemy_page, language: default_language) }

          context "as guest user" do
            it "only returns public pages for current site" do
              get :index, format: :json
              expect(result["pages"].map { |r| r["id"] }).to match_array([
                page.parent_id,
                page.id,
              ])
            end
          end

          context "as author user" do
            before do
              authorize_user(build(:alchemy_dummy_user, :as_author))
            end

            it "returns all pages for current site" do
              get :index, format: :json
              expect(result["pages"].map { |r| r["id"] }).to match_array([
                page.parent_id,
                page.id,
                unpublished_page.id,
              ])
            end
          end
        end

        context "with language_id param" do
          subject { get :index, params: { format: :json, language_id: try(:language)&.id } }

          let!(:default_language_page) { create(:alchemy_page, :public, language: default_language, name: "same-name") }

          context "when a language with that id exists" do
            let(:language) { create(:alchemy_language, :klingon) }
            let!(:default_language_page) { create(:alchemy_page, :public, language: default_language, name: "same-name") }
            let!(:klingon_page) { create(:alchemy_page, :public, language: language, name: "same-name") }

            it "only returns results from that language" do
              subject
              expect(result["pages"].map { |r| r["id"] }).to match_array [language.pages.root.id, klingon_page.id]
            end
          end

          context "when a language with that id does not exist" do
            it "uses the default language" do
              subject
              expect(result["pages"].map { |r| r["id"] }).to include(default_language_page.id)
              expect(result["pages"].map { |r| r["language_code"] }).not_to include("kl")
            end
          end
        end
      end

      describe "#nested" do
        let!(:page) { create(:alchemy_page, :public, page_layout: "contact") }

        it "returns all pages as nested json tree without admin related infos", :aggregate_failures do
          get :nested, params: { format: :json }

          expect(response.status).to eq(200)
          expect(response.media_type).to eq("application/json")

          result = JSON.parse(response.body)

          expect(result).to have_key("pages")
          expect(result["pages"].size).to eq(1)
          expect(result["pages"][0]).to have_key("children")
          expect(result["pages"][0]["children"].size).to eq(1)

          child = result["pages"][0]["children"][0]

          expect(child["name"]).to eq(page.name)
          expect(child).to_not have_key("definition_missing")
          expect(child).to_not have_key("folded")
          expect(child).to_not have_key("locked")
          expect(child).to_not have_key("permissions")
          expect(child).to_not have_key("status_titles")
        end

        context "as author" do
          before do
            authorize_user(build(:alchemy_dummy_user, :as_author))
          end

          it "returns all pages as nested json tree with admin related infos", :aggregate_failures do
            get :nested, params: { format: :json }

            expect(response.status).to eq(200)
            expect(response.media_type).to eq("application/json")

            result = JSON.parse(response.body)

            expect(result).to have_key("pages")
            expect(result["pages"].size).to eq(1)
            expect(result["pages"][0]).to have_key("children")
            expect(result["pages"][0]["children"].size).to eq(1)

            child = result["pages"][0]["children"][0]

            expect(child["name"]).to eq(page.name)
            expect(child).to have_key("definition_missing")
            expect(child).to have_key("folded")
            expect(child).to have_key("locked")
            expect(child).to have_key("permissions")
            expect(child).to have_key("status_titles")
          end
        end

        context "when a page_id is passed" do
          it "returns all pages as nested json from this page only" do
            get :nested, params: { page_id: page.id, format: :json }

            expect(response.status).to eq(200)
            expect(response.media_type).to eq("application/json")

            result = JSON.parse(response.body)

            expect(result).to have_key("pages")
            expect(result["pages"][0]["name"]).to eq(page.name)
          end
        end

        context "when `elements=true` is passed" do
          it "returns all pages as nested json tree with elements included" do
            get :nested, params: { elements: "true", format: :json }

            expect(response.status).to eq(200)
            expect(response.media_type).to eq("application/json")

            result = JSON.parse(response.body)

            expect(result).to have_key("pages")
            expect(result["pages"][0]).to have_key("elements")
          end
        end

        context "when elements is a comma separated list of element names" do
          before do
            %i(headline text contactform).map do |name|
              create(:alchemy_element, name: name, page: page, page_version: page.public_version)
            end
          end

          it "returns all pages as nested json tree with only these elements included" do
            get :nested, params: { elements: "headline,text", format: :json }

            result = JSON.parse(response.body)

            elements = result["pages"][0]["children"][0]["elements"]
            element_names = elements.collect { |element| element["name"] }
            expect(element_names).to include("headline", "text")
            expect(element_names).to_not include("contactform")
          end
        end
      end
    end

    describe "#show" do
      context "for existing page" do
        let(:page) { create(:alchemy_page, :public, urlname: "a-page") }

        it "returns page as json" do
          get :show, params: { urlname: page.urlname, format: :json }

          expect(response.status).to eq(200)
          expect(response.media_type).to eq("application/json")

          result = JSON.parse(response.body)

          expect(result["id"]).to eq(page.id)
          expect(result["url_path"]).to eq("/a-page")
        end

        context "requesting an restricted page" do
          let(:page) { create(:alchemy_page, restricted: true, urlname: "a-page") }

          it "responds with 403" do
            get :show, params: { urlname: page.urlname, format: :json }

            expect(response.status).to eq(403)
            expect(response.media_type).to eq("application/json")

            result = JSON.parse(response.body)

            expect(result).to have_key("error")
            expect(result["error"]).to eq("Not authorized")
          end
        end

        context "requesting a not public page" do
          let(:page) { create(:alchemy_page, urlname: "a-page") }

          it "responds with 403" do
            get :show, params: { urlname: page.urlname, format: :json }

            expect(response.status).to eq(403)
            expect(response.media_type).to eq("application/json")

            result = JSON.parse(response.body)

            expect(result).to have_key("error")
            expect(result["error"]).to eq("Not authorized")
          end
        end
      end

      context "requesting an unknown page" do
        it "responds with 404" do
          get :show, params: { urlname: "not-existing", format: :json }

          expect(response.status).to eq(404)
          expect(response.media_type).to eq("application/json")

          result = JSON.parse(response.body)

          expect(result).to have_key("error")
          expect(result["error"]).to eq("Record not found")
        end

        context "because of requesting not existing language" do
          let(:page) { create(:alchemy_page, :public) }

          it "responds with 404" do
            get :show, params: { urlname: page.urlname, locale: "na", format: :json }
            expect(response.status).to eq(404)
          end
        end
      end

      context "requesting a page with id" do
        let(:page) { create(:alchemy_page, :public) }

        it "responds with json" do
          get :show, params: { urlname: page.id, format: :json }

          expect(response.status).to eq(200)
          expect(response.media_type).to eq("application/json")

          result = JSON.parse(response.body)

          expect(result["id"]).to eq(page.id)
        end
      end

      context "in an environment with multiple languages" do
        let!(:default_language) { create(:alchemy_language, :english, default: true) }
        let(:klingon) { create(:alchemy_language, :klingon) }

        context "having two pages with the same url names in different languages" do
          let!(:english_page) { create(:alchemy_page, :public, language: default_language, name: "same-name") }
          let!(:klingon_page) { create(:alchemy_page, :public, language: klingon, name: "same-name") }

          context "when a locale is given" do
            it "renders the page related to its language" do
              get :show, params: { urlname: "same-name", locale: klingon_page.language_code, format: :json }
              result = JSON.parse(response.body)
              expect(result["id"]).to eq(klingon_page.id)
            end
          end

          context "when no locale is given" do
            it "renders the page of the default language" do
              get :show, params: { urlname: "same-name", format: :json }
              result = JSON.parse(response.body)
              expect(result["id"]).to eq(english_page.id)
            end
          end
        end
      end
    end

    describe "#move" do
      let!(:root_page) { create(:alchemy_page, :language_root) }
      let!(:page) { create(:alchemy_page, parent: root_page) }
      let!(:page_2) { create(:alchemy_page, parent: root_page) }
      let!(:page_3) { create(:alchemy_page, parent: root_page) }

      context "with authorized access" do
        before do
          authorize_user(:as_admin)
        end

        it "returns JSON and moves the page" do
          expect(page.children).to be_empty
          expect(page_3.lft).to eq(6)
          patch :move, params: { id: page_3, target_parent_id: page.id, new_position: 0, format: :json }
          expect(response.status).to eq(200)
          response_json = JSON.parse(response.body)
          expect(response_json["parent_id"]).to eq(page.id)
          expect(page.children).to include(page_3)
        end
      end

      context "with unauthorized access" do
        before do
          authorize_user
        end

        it "returns an unauthorized error" do
          patch :move, params: { id: page_3, target_parent_id: page.id, new_position: 0, format: :json }
          expect(response).to be_forbidden
          response_json = JSON.parse(response.body)
          expect(response_json["error"]).to eq("Not authorized")
        end
      end
    end
  end
end
