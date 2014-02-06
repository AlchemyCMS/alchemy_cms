require 'spec_helper'

module Alchemy
  describe Admin::AttachmentsController do
    let(:attachment) { build_stubbed(:attachment) }

    before do
      sign_in(admin_user)
    end

    describe "#index" do
      it "should always paginate the records" do
        Attachment.should_receive(:find_paginated)
        get :index
      end

      context "when params[:tagged_with] is set" do
        it "should filter the records by tags" do
          Attachment.should_receive(:tagged_with).and_return(Attachment.all)
          get :index, tagged_with: "pdf"
        end
      end

      context "when params[:content_id]" do
        let(:content) { mock_model(Content) }

        context "is set" do
          it "it renders the archive_overlay partial" do
            Content.stub_chain(:select, :find_by).and_return(content)
            get :index, {content_id: content.id}
            expect(response).to render_template(partial: '_archive_overlay')
            assigns(:content).should eq(content)
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

    describe '#show' do
      before do
        Attachment.stub(find: attachment)
      end

      it "renders the show template" do
        get :show, id: attachment.id
        expect(response).to render_template(:show)
      end
    end

    describe "#new" do
      context "in overlay" do
        before do
          controller.stub(:in_overlay?).and_return(true)
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

    describe '#create' do
      subject { post :create, params }

      let(:attachment) { mock_model('Attachment', name: 'contract.pdf', to_jq_upload: {}) }
      let(:params)     { {attachment: {name: ''}} }

      context 'with passing validations' do
        before do
          Attachment.should_receive(:new).and_return(attachment)
          attachment.should_receive(:save).and_return(true)
        end

        context 'if inside of archive overlay' do
          let(:params)  { {attachment: {name: ''}, content_id: 1} }
          let(:content) { mock_model('Content') }

          before do
            Content.stub_chain(:select, :find_by).and_return(content)
          end

          it "assigns lots of instance variables" do
            subject
            assigns(:options).should eq({})
            assigns(:while_assigning).should be_true
            assigns(:content).should eq(content)
            assigns(:swap).should eq(nil)
          end
        end

        it "renders json response with success message" do
          subject
          response.content_type.should eq('application/json')
          response.status.should eq(201)
          json = JSON.parse(response.body)
          json.should have_key('growl_message')
          json.should have_key('files')
        end
      end

      context 'without passing validations' do
        it "renders json response with error message" do
          subject
          response.content_type.should eq('application/json')
          response.status.should eq(422)
          json = JSON.parse(response.body)
          json.should have_key('growl_message')
          json.should have_key('files')
        end
      end
    end

    describe '#update' do
      subject { put :update, attachment: {name: ''} }

      let(:attachment) { build_stubbed(:attachment) }

      before do
        Attachment.stub(find: attachment)
      end

      context 'with passing validations' do
        before do
          attachment.should_receive(:update_attributes).and_return(true)
        end

        it "redirects to index path" do
          should redirect_to admin_attachments_path
        end
      end

      context 'with failing validations' do
        before do
          attachment.stub(update_attributes: false)
          attachment.stub_chain(:errors, :empty?).and_return(false)
        end

        it "renders edit form" do
          should render_template(:edit)
        end
      end
    end

    describe '#destroy' do
      let(:attachment) { build_stubbed(:attachment) }

      before do
        Attachment.stub(find: attachment)
      end

      it "destroys the attachment and sets and success message" do
        attachment.should_receive(:destroy)
        xhr :delete, :destroy
        assigns(:attachment).should eq(attachment)
        assigns(:url).should_not be_blank
        flash[:notice].should_not be_blank
      end
    end

    describe "#download" do
      before do
        Attachment.stub(:find).with("#{attachment.id}").and_return(attachment)
        controller.stub(:render).and_return(nil)
      end

      it "should assign @attachment with Attachment found by id" do
        get :download, id: attachment.id
        expect(assigns(:attachment)).to eq(attachment)
      end

      it "should send the data to the browser" do
        controller.should_receive(:send_data)
        get :download, id: attachment.id
      end
    end
  end
end
