require 'spec_helper'

module Alchemy
  describe ContentsController do
    let(:page)    { build_stubbed(:page) }
    let(:element) { build_stubbed(:element, page: page) }
    let(:content) { build_stubbed(:content, element: element) }

    describe '#show' do
      before { Content.stub(find: content) }

      context "requested for json format" do
        it "should render json response but warns about deprecation" do
          expect(ActiveSupport::Deprecation).to receive(:warn)
          get :show, id: content.id, format: :json
          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')
        end
      end
    end
  end
end
