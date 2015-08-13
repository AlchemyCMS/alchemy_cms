require 'spec_helper'

module Alchemy
  describe Admin::EssencePicturesController do
    before { authorize_user(:as_admin) }

    let(:essence) { EssencePicture.new }
    let(:content) { Content.new }
    let(:picture) { Picture.new }

    describe '#edit' do
      before do
        expect(EssencePicture).to receive(:find).and_return(essence)
        expect(Content).to receive(:find).and_return(content)
      end

      it 'should assign @essence_picture and @content instance variables' do
        alchemy_post :edit, id: 1, content_id: 1
        expect(assigns(:essence_picture)).to be_a(EssencePicture)
        expect(assigns(:content)).to be_a(Content)
      end
    end

    describe '#update' do
      before do
        expect(EssencePicture).to receive(:find).and_return(essence)
        expect(Content).to receive(:find).and_return(content)
      end

      let(:attributes) { { alt_tag: 'Alt Tag', caption: 'Caption', css_class: 'CSS Class', title: 'Title' } }

      it "updates the essence attributes" do
        expect(essence).to receive(:update).and_return(true)
        alchemy_xhr :put, :update, id: 1, essence_picture: attributes
      end
    end

    describe '#assign' do
      let(:content) { create(:content) }

      before do
        expect(Content).to receive(:find).and_return(content)
        expect(content).to receive(:essence).at_least(:once).and_return(essence)
        expect(Picture).to receive(:find_by).and_return(picture)
      end

      it "should assign a Picture" do
        alchemy_xhr :put, :assign, content_id: '1', picture_id: '1'
        expect(assigns(:content).essence.picture).to eq(picture)
      end

      it "updates the content timestamp" do
        expect {
          alchemy_xhr :put, :assign, content_id: '1', picture_id: '1'
        }.to change(content, :updated_at)
      end
    end
  end
end
