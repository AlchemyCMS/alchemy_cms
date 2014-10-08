require 'spec_helper'

module Alchemy
  describe API::PagesController do
    let(:page)    { build_stubbed(:public_page) }

    describe '#show' do
      before { Page.stub(find_by: page) }

      it "responds to json" do
        get :show, id: page.id, format: :json
        expect(response.status).to eq(200)
        expect(response.content_type).to eq('application/json')
      end

      context 'requesting an restricted page' do
        let(:page) { build_stubbed(:page, restricted: true) }

        it "responds with 403" do
          get :show, id: page.id, format: :json
          expect(response.content_type).to eq('application/json')
          expect(response.status).to eq(403)
        end
      end

      context 'requesting a not public page' do
        let(:page) { build_stubbed(:page) }

        it "responds with 403" do
          get :show, id: page.id, format: :json
          expect(response.content_type).to eq('application/json')
          expect(response.status).to eq(403)
        end
      end
    end
  end
end
