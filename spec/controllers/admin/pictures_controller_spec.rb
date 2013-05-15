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

  end
end
