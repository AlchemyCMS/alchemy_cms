require 'spec_helper'

module Alchemy
  describe Api::PagesController do

    describe '#index' do
      let!(:page) { create(:public_page) }

      it "returns all public pages as json objects" do
        alchemy_get :index, format: :json
        expect(response.status).to eq(200)
        expect(response.content_type).to eq('application/json')
        expect(response.body).to eq("{\"pages\":[#{PageSerializer.new(page.parent).to_json},#{PageSerializer.new(page).to_json}]}")
      end

      context 'with page_layout' do
        let!(:other_page) { create(:public_page, page_layout: 'news') }

        it "returns only pages with this page layout" do
          alchemy_get :index, {page_layout: 'news', format: :json}
          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')
          expect(response.body).to eq("{\"pages\":[#{PageSerializer.new(other_page).to_json}]}")
        end
      end

      context 'with empty string as page_layout' do
        it "returns all pages" do
          alchemy_get :index, {page_layout: '', format: :json}
          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')
          expect(response.body).to eq("{\"pages\":[#{PageSerializer.new(page.parent).to_json},#{PageSerializer.new(page).to_json}]}")
        end
      end
    end

    describe '#show' do
      context 'for existing page' do
        let(:page) { build_stubbed(:public_page, urlname: 'a-page') }

        before do
          expect(Page).to receive(:find_by).and_return(page)
        end

        it "returns page as json" do
          alchemy_get :show, {urlname: page.urlname, format: :json}
          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')
          expect(response.body).to eq(PageSerializer.new(page).to_json)
        end

        context 'requesting an restricted page' do
          let(:page) { build_stubbed(:page, restricted: true, urlname: 'a-page') }

          it "responds with 403" do
            alchemy_get :show, {urlname: page.urlname, format: :json}
            expect(response.content_type).to eq('application/json')
            expect(response.status).to eq(403)
            expect(response.body).to eq('{"error":"Not authorized"}')
          end
        end

        context 'requesting a not public page' do
          let(:page) { build_stubbed(:page, urlname: 'a-page') }

          it "responds with 403" do
            alchemy_get :show, {urlname: page.urlname, format: :json}
            expect(response.content_type).to eq('application/json')
            expect(response.status).to eq(403)
            expect(response.body).to eq('{"error":"Not authorized"}')
          end
        end
      end

      context 'requesting an unknown page' do
        it "responds with 404" do
          alchemy_get :show, {urlname: 'not-existing', format: :json}
          expect(response.content_type).to eq('application/json')
          expect(response.status).to eq(404)
          expect(response.body).to eq('{"error":"Record not found"}')
        end
      end

      context 'requesting a page with id' do
        let(:page) { create(:public_page) }

        it "responds with json" do
          alchemy_get :show, {id: page.id, format: :json}
          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')
          expect(response.body).to eq(PageSerializer.new(page).to_json)
        end
      end
    end
  end
end
