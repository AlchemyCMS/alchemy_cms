require 'spec_helper'

module Alchemy
  describe Admin::PictureStylesController do
    before { authorize_user(:as_admin) }

    let(:essence)       { FactoryGirl.create :essence_picture }
    let(:picture_style) { essence.picture_style }

    before do
      expect(PictureStyle).to receive(:find).and_return(picture_style)
    end

    describe '#edit' do
      it "should render the view" do
        alchemy_get :edit, id: 1
        expect(response.status).to eq(200)
      end
    end

    describe '#update' do
      let(:params) { { render_size: '1x1', crop_from: '0x0', crop_size: '100x100' } }

      it "updates the essence attributes" do
        expect(picture_style).to receive(:update_attributes).and_return(true)
        alchemy_xhr :put, :update, id: 1, picture_style: params
      end
    end
  end
end
