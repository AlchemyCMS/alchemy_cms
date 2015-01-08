require 'spec_helper'

module Alchemy
  describe Api::ContentsController do
    describe '#index' do
      let!(:page)    { create(:page) }
      let!(:element) { create(:element, page: page) }
      let!(:content) { create(:content, element: element) }

      it "returns all public contents as json objects" do
        get :index, format: :json
        expect(response.status).to eq(200)
        expect(response.content_type).to eq('application/json')
        expect(response.body).to_not eq('{"contents":[]}')
      end

      context 'with element_id' do
        let!(:other_element) { create(:element, page: page) }
        let!(:other_content) { create(:content, element: other_element) }

        it "returns only contents from this element" do
          get :index, element_id: element.id, format: :json
          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')
          expect(response.body).to_not eq('{"contents":[]}')
          expect(response.body).to_not match(/element_id\"\:#{other_element.id}/)
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

        it "responds to json" do
          get :show, id: content.id, format: :json
          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')
        end

        context 'requesting an restricted content' do
          let(:page) { create(:page, restricted: true) }

          it "responds with 403" do
            get :show, id: content.id, format: :json
            expect(response.content_type).to eq('application/json')
            expect(response.status).to eq(403)
          end
        end
      end

      context 'with element_id and name params given' do
        let!(:page)    { create(:page) }
        let!(:element) { create(:element, page: page) }
        let!(:content) { create(:content, element: element) }

        it 'returns the named content from element with given id.' do
          get :show, element_id: element.id, name: content.name, format: :json
          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')
          expect(response.body).to match(/element_id\"\:#{element.id}/)
          expect(response.body).to match(/name\"\:\"#{content.name}\"/)
        end
      end
    end
  end
end
