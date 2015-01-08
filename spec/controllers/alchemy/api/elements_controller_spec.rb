require 'spec_helper'

module Alchemy
  describe Api::ElementsController do
    describe '#index' do
      let!(:page)    { create(:public_page) }
      let!(:element) { create(:element, page: page) }

      it "returns all public elements as json objects" do
        get :index, format: :json
        expect(response.status).to eq(200)
        expect(response.content_type).to eq('application/json')
        expect(response.body).to_not eq('{"elements":[]}')
      end

      context 'with page_id param' do
        let!(:other_page)    { create(:public_page) }
        let!(:other_element) { create(:element, page: other_page) }

        it "returns only elements from this element" do
          get :index, page_id: other_page.id, format: :json
          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')
          expect(response.body).to_not eq('{"elements":[]}')
          expect(response.body).to match(/page_id\"\:#{other_page.id}/)
          expect(response.body).to_not match(/page_id\"\:#{page.id}/)
        end
      end

      context 'with named param' do
        let!(:other_element) { create(:element, page: page, name: 'news') }

        it "returns only elements named like this." do
          get :index, named: 'news', format: :json
          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')
          expect(response.body).to_not eq('{"elements":[]}')
          expect(response.body).to match(/name\"\:\"#{other_element.name}\"/)
          expect(response.body).to_not match(/name\"\:\"#{element.name}\"/)
        end
      end
    end

    describe '#show' do
      let(:page)    { build_stubbed(:page) }
      let(:element) { build_stubbed(:element, page: page, position: 1) }

      before do
        expect(Element).to receive(:find).and_return(element)
      end

      it "responds to json" do
        get :show, id: element.id, format: :json
        expect(response.status).to eq(200)
        expect(response.content_type).to eq('application/json')
      end

      context 'requesting an restricted element' do
        let(:page) { build_stubbed(:page, restricted: true) }

        it "responds with 403" do
          get :show, id: element.id, format: :json
          expect(response.content_type).to eq('application/json')
          expect(response.status).to eq(403)
        end
      end
    end
  end
end
