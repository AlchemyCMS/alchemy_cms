require 'spec_helper'

module Alchemy
  describe Api::ElementsController do
    describe '#index' do
      let(:page) do
        page = create(:alchemy_page, :public)
        # TODO: Investigate why this is horribly broken in AR!
        page.build_public_version(page_id: page.id)
        page.save!
        page
      end

      before do
        create_list(:alchemy_element, 2, page_version: page.public_version)
      end

      it "returns all public elements as json objects" do
        alchemy_get :index, format: :json

        expect(response.status).to eq(200)
        expect(response.content_type).to eq('application/json')

        result = JSON.parse(response.body)

        expect(result).to have_key('elements')
        expect(result['elements'].size).to eq(Alchemy::Element.count)
      end

      context 'with page_id param' do
        let!(:other_page)    { create(:alchemy_page, :public) }
        let!(:other_element) { create(:alchemy_element, page: other_page) }

        it "returns only elements from this page" do
          alchemy_get :index, page_id: other_page.id, format: :json

          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')

          result = JSON.parse(response.body)

          expect(result).to have_key('elements')
          expect(result['elements'].size).to eq(1)
          expect(result['elements'][0]['page_id']).to eq(other_page.id)
        end
      end

      context 'with empty page_id param' do
        it "returns all elements" do
          alchemy_get :index, page_id: '', format: :json

          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')

          result = JSON.parse(response.body)

          expect(result).to have_key('elements')
          expect(result['elements'].size).to eq(Alchemy::Element.count)
        end
      end

      context 'with named param' do
        let!(:other_element) { create(:alchemy_element, page: page, name: 'news') }

        it "returns only elements named like this." do
          alchemy_get :index, named: 'news', format: :json

          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')

          result = JSON.parse(response.body)

          expect(result).to have_key('elements')
          expect(result['elements'].size).to eq(1)
          expect(result['elements'][0]['name']).to eq('news')
        end
      end

      context 'with empty named param' do
        it "returns all elements" do
          alchemy_get :index, named: '', format: :json

          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')

          result = JSON.parse(response.body)

          expect(result).to have_key('elements')
          expect(result['elements'].size).to eq(Alchemy::Element.count)
        end
      end
    end

    describe '#show' do
      let(:page)    { build_stubbed(:alchemy_page) }
      let(:element) { build_stubbed(:alchemy_element, page: page, position: 1) }

      before do
        expect(Element).to receive(:find).and_return(element)
      end

      it "returns element as json" do
        alchemy_get :show, id: element.id, format: :json

        expect(response.status).to eq(200)
        expect(response.content_type).to eq('application/json')

        result = JSON.parse(response.body)

        expect(result['id']).to eq(element.id)
      end

      context 'requesting an restricted element' do
        let(:page) { build_stubbed(:alchemy_page, restricted: true) }

        it "responds with 403" do
          alchemy_get :show, id: element.id, format: :json

          expect(response.status).to eq(403)
          expect(response.content_type).to eq('application/json')

          result = JSON.parse(response.body)

          expect(result).to have_key('error')
          expect(result['error']).to eq("Not authorized")
        end
      end
    end
  end
end
