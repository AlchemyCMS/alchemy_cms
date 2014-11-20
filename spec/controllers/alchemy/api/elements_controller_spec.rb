require 'spec_helper'

module Alchemy
  describe API::ElementsController do
    let(:page)    { build_stubbed(:page) }
    let(:element) { build_stubbed(:element, page: page) }

    describe '#show' do
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
