# frozen_string_literal: true

require 'spec_helper'

module Alchemy
  describe Api::ContentsController do
    routes { Alchemy::Engine.routes }

    describe '#index' do
      let!(:page)    { create(:alchemy_page) }
      let!(:element) { create(:alchemy_element, page: page) }
      let!(:content) { create(:alchemy_content, element: element) }

      it "returns all public contents as json objects" do
        get :index, params: {format: :json}

        expect(response.status).to eq(200)
        expect(response.content_type).to eq('application/json')

        result = JSON.parse(response.body)

        expect(result).to have_key("contents")
        expect(result['contents'].size).to eq(Alchemy::Content.count)
      end

      context 'with element_id' do
        let!(:other_element) { create(:alchemy_element, page: page) }
        let!(:other_content) { create(:alchemy_content, element: other_element) }

        it "returns only contents from this element" do
          get :index, params: {element_id: other_element.id, format: :json}

          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')

          result = JSON.parse(response.body)

          expect(result).to have_key("contents")
          expect(result['contents'].size).to eq(1)
          expect(result['contents'][0]['element_id']).to eq(other_element.id)
        end
      end

      context 'with empty element_id' do
        it "returns all contents" do
          get :index, params: {element_id: element.id, format: :json}

          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')

          result = JSON.parse(response.body)

          expect(result).to have_key("contents")
          expect(result['contents'].size).to eq(Alchemy::Content.count)
        end
      end

      context 'as author' do
        before do
          authorize_user(build(:alchemy_dummy_user, :as_author))
        end

        it "returns all contents" do
          get :index, params: {format: :json}

          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')

          result = JSON.parse(response.body)

          expect(result).to have_key('contents')
          expect(result['contents'].size).to eq(Alchemy::Content.count)
        end
      end
    end

    describe '#show' do
      context 'with no other params given' do
        let(:page)    { create(:alchemy_page) }
        let(:element) { create(:alchemy_element, page: page) }
        let(:content) { create(:alchemy_content, element: element) }

        before do
          expect(Content).to receive(:find).and_return(content)
        end

        it "returns content as json" do
          get :show, params: {id: content.id, format: :json}

          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')

          result = JSON.parse(response.body)

          expect(result['id']).to eq(content.id)
        end

        context 'requesting an restricted content' do
          let(:page) { create(:alchemy_page, restricted: true) }

          it "responds with 403" do
            get :show, params: {id: content.id, format: :json}

            expect(response.content_type).to eq('application/json')
            expect(response.status).to eq(403)

            result = JSON.parse(response.body)

            expect(result).to have_key("error")
            expect(result['error']).to eq("Not authorized")
          end
        end
      end

      context 'with element_id and name params given' do
        let!(:page)    { create(:alchemy_page) }
        let!(:element) { create(:alchemy_element, page: page) }
        let!(:content) { create(:alchemy_content, element: element) }

        it 'returns the named content from element with given id.' do
          get :show, params: {element_id: element.id, name: content.name, format: :json}

          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')

          result = JSON.parse(response.body)

          expect(result['id']).to eq(content.id)
        end
      end

      context 'with empty element_id or name param' do
        it 'returns 404 error.' do
          get :show, params: {element_id: '', name: '', format: :json}

          expect(response.status).to eq(404)
          expect(response.content_type).to eq('application/json')

          result = JSON.parse(response.body)

          expect(result).to have_key("error")
          expect(result['error']).to eq("Record not found")
        end
      end
    end
  end
end
