require 'spec_helper'

module Alchemy
  describe Api::ElementsController do
    # We need to be sure, that the timestamps are always the same,
    # while comparing json objects
    before do
      allow_any_instance_of(Alchemy::Element).
        to receive(:created_at).and_return(Time.now)
      allow_any_instance_of(Alchemy::Element).
        to receive(:updated_at).and_return(Time.now)
    end

    describe '#index' do
      let!(:page)    { create(:public_page) }
      let!(:element) { create(:element, page: page) }

      it "returns all public elements as json objects" do
        alchemy_get :index, format: :json
        expect(response.status).to eq(200)
        expect(response.content_type).to eq('application/json')
        expect(response.body).to_not eq('{"elements:[]"}')
        expect(response.body).to eq("{\"elements\":[#{ElementSerializer.new(element).to_json}]}")
      end

      context 'with page_id param' do
        let!(:other_page)    { create(:public_page) }
        let!(:other_element) { create(:element, page: other_page) }

        it "returns only elements from this page" do
          alchemy_get :index, page_id: other_page.id, format: :json
          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')
          expect(response.body).to eq("{\"elements\":[#{ElementSerializer.new(other_element).to_json}]}")
        end
      end

      context 'with empty page_id param' do
        it "returns all elements" do
          alchemy_get :index, page_id: '', format: :json
          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')
          expect(response.body).to_not eq('{"elements:[]"}')
          expect(response.body).to eq("{\"elements\":[#{ElementSerializer.new(element).to_json}]}")
        end
      end

      context 'with named param' do
        let!(:other_element) { create(:element, page: page, name: 'news') }

        it "returns only elements named like this." do
          alchemy_get :index, named: 'news', format: :json
          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')
          expect(response.body).to eq("{\"elements\":[#{ElementSerializer.new(other_element).to_json}]}")
        end
      end

      context 'with empty named param' do
        it "returns all elements" do
          alchemy_get :index, named: '', format: :json
          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')
          expect(response.body).to_not eq('{"elements:[]"}')
          expect(response.body).to eq("{\"elements\":[#{ElementSerializer.new(element).to_json}]}")
        end
      end
    end

    describe '#show' do
      let(:page)    { build_stubbed(:page) }
      let(:element) { build_stubbed(:element, page: page, position: 1) }

      before do
        expect(Element).to receive(:find).and_return(element)
      end

      it "returns element as json" do
        alchemy_get :show, id: element.id, format: :json
        expect(response.status).to eq(200)
        expect(response.content_type).to eq('application/json')
        expect(response.body).to eq(ElementSerializer.new(element).to_json)
      end

      context 'requesting an restricted element' do
        let(:page) { build_stubbed(:page, restricted: true) }

        it "responds with 403" do
          alchemy_get :show, id: element.id, format: :json
          expect(response.content_type).to eq('application/json')
          expect(response.status).to eq(403)
          expect(response.body).to eq('{"error":"Not authorized"}')
        end
      end
    end
  end
end
