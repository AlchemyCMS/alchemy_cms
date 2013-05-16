require 'spec_helper'

module Alchemy
  describe Admin::AttachmentsController do

    before do
      sign_in :user, FactoryGirl.create(:admin_user)
    end
    
    describe "#index" do

      it "should always paginate the records" do
        Attachment.should_receive(:find_paginated)
        get :index
      end

      context "when params[:tagged_with] is set" do
        it "should filter the records by tags" do
          Attachment.should_receive(:tagged_with).and_return(Attachment.scoped)
          get :index, tagged_with: "pdf"
        end
      end

      context "when params[:content_id]" do
        render_views

        context "is set" do
          it "should render the archive_overlay partial" do
            Content.stub!(:find).with('1', {:select => 'id'}).and_return(mock_model(Content))
            get :index, {content_id: 1, format: :html}
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
    
    describe "#new" do
      
      context "in overlay" do

        before do
          controller.stub!(:in_overlay?).and_return(true)
          Content.stub(:find).and_return(mock_model('Content'))
        end

        it "should set @while_assigning to true" do
          get :new
          assigns(:while_assigning).should eq(true)
        end

        it "should set @swap to params[:swap]" do
          get :new, swap: 'true'
          assigns(:swap).should eq('true')
        end
      end

    end

  end
end