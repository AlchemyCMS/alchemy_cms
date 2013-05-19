
require 'spec_helper'

module Alchemy
  describe Admin::EssencePicturesController do

    before do
      sign_in :user, FactoryGirl.create(:admin_user)
    end

    let(:essence) { EssencePicture.new }
    let(:content) { Content.new }
    let(:picture) { Picture.new }

    describe '#edit' do
      before do
        EssencePicture.stub!(:find).and_return(essence)
        Content.stub!(:find).and_return(content)
      end

      it 'should assign @essence_picture and @content instance variables' do
        post :edit, id: 1, content_id: 1
        expect(assigns(:essence_picture)).to be_a(EssencePicture)
        expect(assigns(:content)).to be_a(Content)
      end
    end
    
    describe '#assign' do
      before do
        Content.stub!(:find_by_id).and_return(content)
        Content.any_instance.stub(:essence).and_return(essence)
        Picture.stub!(:find_by_id).and_return(picture)
      end

      it "should assign a Picture" do
        put :assign, id: '1', picture_id: '1', format: 'js'
        expect(assigns(:content).essence.picture).to eq(picture)
      end
    end

  end
end