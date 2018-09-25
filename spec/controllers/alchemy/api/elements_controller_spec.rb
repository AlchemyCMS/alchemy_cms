# frozen_string_literal: true

require 'spec_helper'

module Alchemy
  describe Api::ElementsController do
    routes { Alchemy::Engine.routes }

    describe '#index' do
      let(:page) { create(:alchemy_page, :public) }

      before do
        2.times { create(:alchemy_element, page: page) }
        create(:alchemy_element, :nested, page: page)
      end

      it "returns all public not nested elements as json objects" do
        get :index, params: {format: :json}

        expect(response.status).to eq(200)
        expect(response.content_type).to eq('application/json')

        result = JSON.parse(response.body)
        expect(result).to have_key('elements')
        expect(result['elements'].last['nested_elements']).to_not be_empty
        expect(result['elements'].size).to eq(Alchemy::Element.not_nested.count)
      end

      context 'with page_id param' do
        let!(:other_page)    { create(:alchemy_page, :public) }
        let!(:other_element) { create(:alchemy_element, page: other_page) }

        it "returns only elements from this page" do
          get :index, params: {page_id: other_page.id, format: :json}

          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')

          result = JSON.parse(response.body)

          expect(result).to have_key('elements')
          expect(result['elements'].size).to eq(1)
          expect(result['elements'][0]['page_id']).to eq(other_page.id)
        end
      end

      context 'with empty page_id param' do
        it "returns all not nested elements" do
          get :index, params: {page_id: '', format: :json}

          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')

          result = JSON.parse(response.body)

          expect(result).to have_key('elements')
          expect(result['elements'].size).to eq(Alchemy::Element.not_nested.count)
        end
      end

      context 'with named param' do
        let!(:other_element) { create(:alchemy_element, page: page, name: 'news') }

        it "returns only elements named like this." do
          get :index, params: {named: 'news', format: :json}

          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')

          result = JSON.parse(response.body)

          expect(result).to have_key('elements')
          expect(result['elements'].size).to eq(1)
          expect(result['elements'][0]['name']).to eq('news')
        end
      end

      context 'with empty named param' do
        it "returns all not nested elements" do
          get :index, params: {named: '', format: :json}

          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')

          result = JSON.parse(response.body)

          expect(result).to have_key('elements')
          expect(result['elements'].size).to eq(Alchemy::Element.not_nested.count)
        end
      end

      context 'as author' do
        before do
          authorize_user(build(:alchemy_dummy_user, :as_author))
        end

        it "returns all not nested elements" do
          get :index, params: {format: :json}

          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')

          result = JSON.parse(response.body)

          expect(result).to have_key('elements')
          expect(result['elements'].size).to eq(Alchemy::Element.not_nested.count)
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
        get :show, params: {id: element.id, format: :json}

        expect(response.status).to eq(200)
        expect(response.content_type).to eq('application/json')

        result = JSON.parse(response.body)

        expect(result['id']).to eq(element.id)
      end

      context 'requesting an restricted element' do
        let(:page) { build_stubbed(:alchemy_page, restricted: true) }

        it "responds with 403" do
          get :show, params: {id: element.id, format: :json}

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
