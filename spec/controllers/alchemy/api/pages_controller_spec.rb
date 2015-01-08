require 'spec_helper'

module Alchemy
  describe Api::PagesController do

    describe '#index' do
      let!(:page)    { create(:public_page) }

      it "returns all public pages as json objects" do
        get :index, format: :json
        expect(response.status).to eq(200)
        expect(response.content_type).to eq('application/json')
        expect(response.body).to_not eq('{"pages":[]}')
      end

      context 'with page_layout' do
        let!(:other_page) { create(:public_page, page_layout: 'news') }

        it "returns only pages from this element" do
          get :index, page_layout: 'news', format: :json
          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')
          expect(response.body).to_not eq('{"pages":[]}')
          expect(response.body).to_not match(/page_layout\"\:#{page.page_layout}/)
        end
      end
    end

    describe '#show' do
      context 'for existing page' do
        let(:page) { build_stubbed(:public_page) }

        before do
          expect(Page).to receive(:find_by).and_return(page)
        end

        it "responds to json" do
          get :show, urlname: page.urlname, format: :json
          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')
        end

        context 'requesting an restricted page' do
          let(:page) { build_stubbed(:page, restricted: true) }

          it "responds with 403" do
            get :show, urlname: page.urlname, format: :json
            expect(response.content_type).to eq('application/json')
            expect(response.status).to eq(403)
            expect(response.body).to eq('{"error":"Not authorized"}')
          end
        end

        context 'requesting a not public page' do
          let(:page) { build_stubbed(:page) }

          it "responds with 403" do
            get :show, urlname: page.urlname, format: :json
            expect(response.content_type).to eq('application/json')
            expect(response.status).to eq(403)
            expect(response.body).to eq('{"error":"Not authorized"}')
          end
        end
      end

      context 'requesting an unknown page' do
        it "responds with 404" do
          get :show, urlname: 'not-existing', format: :json
          expect(response.content_type).to eq('application/json')
          expect(response.status).to eq(404)
          expect(response.body).to eq('{"error":"Record not found"}')
        end
      end

      context 'requesting a page with id' do
        let(:page) { create(:public_page) }

        it "responds with json" do
          get :show, id: page.id, format: :json
          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')
        end
      end
    end
  end
end
