require 'spec_helper'

module Alchemy
  describe API::ContentsController do
    let(:page)    { build_stubbed(:page) }
    let(:element) { build_stubbed(:element, page: page, position: 1) }
    let(:content) { build_stubbed(:content, element: element) }

    describe '#show' do
      before do
        expect(Content).to receive(:find).and_return(content)
      end

      it "responds to json" do
        get :show, id: content.id, format: :json
        expect(response.status).to eq(200)
        expect(response.content_type).to eq('application/json')
      end

      context 'requesting an restricted content' do
        let(:page) { build_stubbed(:page, restricted: true) }

        it "responds with 403" do
          get :show, id: content.id, format: :json
          expect(response.content_type).to eq('application/json')
          expect(response.status).to eq(403)
        end
      end
    end
  end
end
