# frozen_string_literal: true

require 'spec_helper'

module Alchemy
  describe Api::PagesController do
    routes { Alchemy::Engine.routes }

    describe '#index' do
      let!(:page) { create(:alchemy_page, :public) }

      it "returns all public pages as json objects" do
        get :index, params: {format: :json}

        expect(response.status).to eq(200)
        expect(response.content_type).to eq('application/json')

        result = JSON.parse(response.body)

        expect(result).to have_key('pages')
        expect(result['pages'].size).to eq(2)
      end

      context 'with page_layout' do
        let!(:other_page) { create(:alchemy_page, :public, page_layout: 'news') }

        it "returns only page with this page layout" do
          get :index, params: {page_layout: 'news', format: :json}

          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')

          result = JSON.parse(response.body)

          expect(result).to have_key('pages')
          expect(result['pages'].size).to eq(1)
        end
      end

      context 'with empty string as page_layout' do
        it "returns all pages" do
          get :index, params: {page_layout: '', format: :json}

          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')

          result = JSON.parse(response.body)

          expect(result).to have_key('pages')
          expect(result['pages'].size).to eq(2)
        end
      end

      context 'as author' do
        before do
          authorize_user(build(:alchemy_dummy_user, :as_author))
        end

        it "returns all pages" do
          get :index, params: {format: :json}

          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')

          result = JSON.parse(response.body)

          expect(result).to have_key('pages')
          expect(result['pages'].size).to eq(Alchemy::Page.count)
        end
      end
    end

    describe '#nested' do
      let!(:page) { create(:alchemy_page, :public, page_layout: 'contact') }

      it "returns all pages as nested json tree without admin related infos", :aggregate_failures do
        get :nested, params: {format: :json}

        expect(response.status).to eq(200)
        expect(response.content_type).to eq('application/json')

        result = JSON.parse(response.body)

        expect(result).to have_key('pages')
        expect(result['pages'].size).to eq(1)
        expect(result['pages'][0]).to have_key('children')
        expect(result['pages'][0]['children'].size).to eq(1)

        child = result['pages'][0]['children'][0]

        expect(child['name']).to eq(page.name)
        expect(child).to_not have_key('definition_missing')
        expect(child).to_not have_key('folded')
        expect(child).to_not have_key('locked')
        expect(child).to_not have_key('permissions')
        expect(child).to_not have_key('status_titles')
      end

      context "as author" do
        before do
          authorize_user(build(:alchemy_dummy_user, :as_author))
        end

        it "returns all pages as nested json tree with admin related infos", :aggregate_failures do
          get :nested, params: {format: :json}

          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')

          result = JSON.parse(response.body)

          expect(result).to have_key('pages')
          expect(result['pages'].size).to eq(1)
          expect(result['pages'][0]).to have_key('children')
          expect(result['pages'][0]['children'].size).to eq(1)

          child = result['pages'][0]['children'][0]

          expect(child['name']).to eq(page.name)
          expect(child).to have_key('definition_missing')
          expect(child).to have_key('folded')
          expect(child).to have_key('locked')
          expect(child).to have_key('permissions')
          expect(child).to have_key('status_titles')
        end
      end

      context "when a page_id is passed" do
        it 'returns all pages as nested json from this page only' do
          get :nested, params: {page_id: page.id, format: :json}

          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')

          result = JSON.parse(response.body)

          expect(result).to have_key('pages')
          expect(result['pages'][0]['name']).to eq(page.name)
        end
      end

      context "when `elements=true` is passed" do
        it 'returns all pages as nested json tree with elements included' do
          get :nested, params: {elements: 'true', format: :json}

          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')

          result = JSON.parse(response.body)

          expect(result).to have_key('pages')
          expect(result['pages'][0]).to have_key('elements')
        end

        context "and elements is a comma separated list of element names" do
          before do
            page.send(:autogenerate_elements)
          end

          it 'returns all pages as nested json tree with only these elements included' do
            get :nested, params: {elements: 'headline,text', format: :json}

            result = JSON.parse(response.body)

            elements = result['pages'][0]['children'][0]['elements']
            element_names = elements.collect { |element| element['name'] }
            expect(element_names).to include('headline', 'text')
            expect(element_names).to_not include('contactform')
          end
        end
      end
    end

    describe '#show' do
      context 'for existing page' do
        let(:page) { build_stubbed(:alchemy_page, :public, urlname: 'a-page') }

        before do
          expect(Page).to receive(:find_by).and_return(page)
        end

        it "returns page as json" do
          get :show, params: {urlname: page.urlname, format: :json}

          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')

          result = JSON.parse(response.body)

          expect(result['id']).to eq(page.id)
        end

        context 'requesting an restricted page' do
          let(:page) { build_stubbed(:alchemy_page, restricted: true, urlname: 'a-page') }

          it "responds with 403" do
            get :show, params: {urlname: page.urlname, format: :json}

            expect(response.status).to eq(403)
            expect(response.content_type).to eq('application/json')

            result = JSON.parse(response.body)

            expect(result).to have_key('error')
            expect(result['error']).to eq("Not authorized")
          end
        end

        context 'requesting a not public page' do
          let(:page) { build_stubbed(:alchemy_page, urlname: 'a-page') }

          it "responds with 403" do
            get :show, params: {urlname: page.urlname, format: :json}

            expect(response.status).to eq(403)
            expect(response.content_type).to eq('application/json')

            result = JSON.parse(response.body)

            expect(result).to have_key('error')
            expect(result['error']).to eq("Not authorized")
          end
        end
      end

      context 'requesting an unknown page' do
        it "responds with 404" do
          get :show, params: {urlname: 'not-existing', format: :json}

          expect(response.status).to eq(404)
          expect(response.content_type).to eq('application/json')

          result = JSON.parse(response.body)

          expect(result).to have_key('error')
          expect(result['error']).to eq("Record not found")
        end

        context "because of requesting not existing language" do
          let(:page) { create(:alchemy_page, :public) }

          it "responds with 404" do
            get :show, params: {urlname: page.urlname, locale: 'na', format: :json}
            expect(response.status).to eq(404)
          end
        end
      end

      context 'requesting a page with id' do
        let(:page) { create(:alchemy_page, :public) }

        it "responds with json" do
          get :show, params: {id: page.id, format: :json}

          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')

          result = JSON.parse(response.body)

          expect(result['id']).to eq(page.id)
        end
      end

      context 'in an environment with multiple languages' do
        let(:klingon) { create(:alchemy_language, :klingon) }

        context 'having two pages with the same url names in different languages' do
          let!(:english_page) { create(:alchemy_page, :public, language: Language.default, name: "same-name") }
          let!(:klingon_page) { create(:alchemy_page, :public, language: klingon, name: "same-name") }

          context 'when a locale is given' do
            it 'renders the page related to its language' do
              get :show, params: {urlname: "same-name", locale: klingon_page.language_code, format: :json}
              result = JSON.parse(response.body)
              expect(result['id']).to eq(klingon_page.id)
            end
          end

          context 'when no locale is given' do
            it 'renders the page of the default language' do
              get :show, params: {urlname: "same-name", format: :json}
              result = JSON.parse(response.body)
              expect(result['id']).to eq(english_page.id)
            end
          end
        end
      end
    end
  end
end
