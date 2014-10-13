require 'spec_helper'

module Alchemy
  describe API::PagesController do
    let(:page) { build_stubbed(:public_page) }

    describe '#show' do
      context 'for existing page' do
        before { Page.stub(find_by!: page) }

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
          get :show, urlname: 1234, format: :json
          expect(response.content_type).to eq('application/json')
          expect(response.status).to eq(404)
          expect(response.body).to eq('{"error":"Record not found"}')
        end
      end
    end
  end
end
