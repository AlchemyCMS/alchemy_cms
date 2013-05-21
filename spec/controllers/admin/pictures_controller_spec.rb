require 'spec_helper'

module Alchemy
  describe Admin::PicturesController do

    before do
      sign_in :user, FactoryGirl.create(:admin_user)
    end
    
    describe "#index" do
      it "should always paginate the records" do
        Picture.should_receive(:find_paginated)
        get :index
      end

      context "when params[:tagged_with] is set" do
        it "should filter the records by tags" do
          Picture.should_receive(:tagged_with).and_return(Picture.scoped)
          get :index, tagged_with: "red"
        end
      end

      context "when params[:content_id]" do
        render_views

        context "is set" do
          it "should render the archive_overlay partial" do
            Element.stub!(:find).with('1', {:select => 'id'}).and_return(mock_model(Element))
            get :index, {element_id: 1, format: :html}
            expect(response).to render_template(partial: '_archive_overlay')
          end
        end

        context "is not set" do
          it "should render the default index view" do
            get :index
            expect(response).to render_template(:index)
          end
        end

      end
    end

    describe "#delete_multiple" do
      let(:deletable_picture) { mock_model('Picture', name: 'pic of the pig', deletable?: true) }
      let(:not_deletable_picture) { mock_model('Picture', name: 'pic of the chick', deletable?: false) }

      context "no picture_ids given" do
        it "should give a warning about not deleting any pictures" do
          delete :delete_multiple, picture_ids: ''
          expect(flash[:warn]).to match('Could not delete Pictures')
        end
      end

      context "picture_ids given" do
        context "all are deletable" do
          before do
            Picture.stub!(:find).and_return([deletable_picture])
          end

          it "should delete the pictures give a notice about deleting them" do
            delete :delete_multiple, picture_ids: "#{deletable_picture.id}"
            expect(flash[:notice]).to match('successfully')
          end
        end

        context "deletable and not deletable" do
          before do
            Picture.stub!(:find).and_return([deletable_picture, not_deletable_picture])
          end

          it "should give a warning for the non deletable pictures and delete the others" do
            deletable_picture.should_receive(:destroy)
            delete :delete_multiple, picture_ids: "#{deletable_picture.id},#{not_deletable_picture.id}"
            expect(flash[:warn]).to match('could not be deleted')
          end
        end
      end
    end

  end
end
