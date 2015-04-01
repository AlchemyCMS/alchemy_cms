require 'spec_helper'

module Alchemy
  describe Api::ContentsController do
    # We need to be sure, that the timestamps are always the same,
    # while comparing json objects
    before do
      allow_any_instance_of(Alchemy::Content).
        to receive(:created_at).and_return(Time.now)
      allow_any_instance_of(Alchemy::Content).
        to receive(:updated_at).and_return(Time.now)
      allow_any_instance_of(Alchemy::EssenceText).
        to receive(:created_at).and_return(Time.now)
      allow_any_instance_of(Alchemy::EssenceText).
        to receive(:updated_at).and_return(Time.now)
      allow_any_instance_of(Alchemy::EssenceRichtext).
        to receive(:created_at).and_return(Time.now)
      allow_any_instance_of(Alchemy::EssenceRichtext).
        to receive(:updated_at).and_return(Time.now)
    end

    describe '#index' do
      let!(:page)    { create(:page) }
      let!(:element) { create(:element, page: page) }
      let!(:content) { create(:content, element: element) }

      it "returns all public contents as json objects" do
        alchemy_get :index, format: :json
        expect(response.status).to eq(200)
        expect(response.content_type).to eq('application/json')
        expect(response.body).to eq("{\"contents\":[#{ContentSerializer.new(content).to_json}]}")
      end

      context 'with element_id' do
        let!(:other_element) { create(:element, page: page) }
        let!(:other_content) { create(:content, element: other_element) }

        it "returns only contents from this element" do
          alchemy_get :index, element_id: other_element.id, format: :json
          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')
          expect(response.body).to eq("{\"contents\":[#{ContentSerializer.new(other_content).to_json}]}")
        end
      end

      context 'with empty element_id' do
        it "returns all contents" do
          alchemy_get :index, element_id: element.id, format: :json
          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')
          expect(response.body).to eq("{\"contents\":[#{ContentSerializer.new(content).to_json}]}")
        end
      end
    end

    describe '#show' do
      context 'with no other params given' do
        let(:page)    { create(:page) }
        let(:element) { create(:element, page: page) }
        let(:content) { create(:content, element: element) }

        before do
          expect(Content).to receive(:find).and_return(content)
        end

        it "returns content as json" do
          alchemy_get :show, id: content.id, format: :json
          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')
          expect(response.body).to eq(ContentSerializer.new(content).to_json)
        end

        context 'requesting an restricted content' do
          let(:page) { create(:page, restricted: true) }

          it "responds with 403" do
            alchemy_get :show, id: content.id, format: :json
            expect(response.content_type).to eq('application/json')
            expect(response.status).to eq(403)
            expect(response.body).to eq('{"error":"Not authorized"}')
          end
        end
      end

      context 'with element_id and name params given' do
        let!(:page)    { create(:page) }
        let!(:element) { create(:element, page: page) }
        let!(:content) { create(:content, element: element) }

        it 'returns the named content from element with given id.' do
          alchemy_get :show, element_id: element.id, name: content.name, format: :json
          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')
          expect(response.body).to eq(ContentSerializer.new(content).to_json)
        end
      end

      context 'with empty element_id or name param' do
        it 'returns 404 error.' do
          alchemy_get :show, element_id: '', name: '', format: :json
          expect(response.status).to eq(404)
          expect(response.content_type).to eq('application/json')
          expect(response.body).to eq("{\"error\":\"Record not found\"}")
        end
      end
    end
  end
end
