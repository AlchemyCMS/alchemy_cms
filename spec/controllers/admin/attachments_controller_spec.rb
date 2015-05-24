require 'spec_helper'

module Alchemy
  describe Admin::AttachmentsController do
    let(:attachment) { build_stubbed(:attachment) }

    before do
      authorize_user(:as_admin)
    end

    describe "#index" do
      it "should always paginate the records" do
        expect(Attachment).to receive(:find_paginated)
        alchemy_get :index
      end

      context "when params[:tagged_with] is set" do
        it "should filter the records by tags" do
          expect(Attachment).to receive(:tagged_with).and_return(Attachment.all)
          alchemy_get :index, tagged_with: "pdf"
        end
      end

      context "when params[:content_id]" do
        let(:content) { mock_model(Content) }

        context "is set" do
          it "it renders the archive_overlay partial" do
            expect(Content).to receive(:find_by).and_return(content)
            alchemy_get :index, {content_id: content.id}
            expect(response).to render_template(partial: '_archive_overlay')
            expect(assigns(:content)).to eq(content)
          end
        end

        context "is not set" do
          it "should render the default index view" do
            alchemy_get :index
            expect(response).to render_template(:index)
          end
        end
      end

      describe 'only and expect options' do
        let!(:png) { create(:attachment) }
        let!(:jpg) { create(:attachment, file: File.new(File.expand_path('../../../../spec/fixtures/image3.jpeg', __FILE__))) }

        context 'with params[:only]' do
          it 'only loads attachments with matching content type' do
            alchemy_get :index, only: 'jpeg'
            expect(assigns(:attachments).to_a).to eq([jpg])
            expect(assigns(:attachments).to_a).to_not eq([png])
          end
        end

        context 'with params[:except]' do
          it 'does not load attachments with matching content type' do
            alchemy_get :index, except: 'jpeg'
            expect(assigns(:attachments).to_a).to eq([png])
            expect(assigns(:attachments).to_a).to_not eq([jpg])
          end
        end
      end
    end

    describe '#show' do
      before do
        expect(Attachment).to receive(:find).and_return(attachment)
      end

      it "renders the show template" do
        alchemy_get :show, id: attachment.id
        expect(response).to render_template(:show)
      end
    end

    describe "#new" do
      context "in overlay" do
        before do
          expect(controller).to receive(:in_overlay?).and_return(true)
          expect(Content).to receive(:find_by).and_return(mock_model('Content'))
        end

        it "should set @while_assigning to true" do
          alchemy_get :new
          expect(assigns(:while_assigning)).to eq(true)
        end

        it "should set @swap to params[:swap]" do
          alchemy_get :new, swap: 'true'
          expect(assigns(:swap)).to eq('true')
        end
      end
    end

    describe '#create' do
      subject { alchemy_post :create, params }

      let(:attachment) { mock_model('Attachment', name: 'contract.pdf', to_jq_upload: {}) }
      let(:params)     { {attachment: {name: ''}} }

      context 'with passing validations' do
        before do
          expect(Attachment).to receive(:new).and_return(attachment)
          expect(attachment).to receive(:save).and_return(true)
        end

        context 'if inside of archive overlay' do
          let(:params)  { {attachment: {name: ''}, content_id: 1} }
          let(:content) { mock_model('Content') }

          before do
            expect(Content).to receive(:find_by).and_return(content)
          end

          it "assigns lots of instance variables" do
            subject
            expect(assigns(:options)).to eq({})
            expect(assigns(:while_assigning)).to be_truthy
            expect(assigns(:content)).to eq(content)
            expect(assigns(:swap)).to eq(nil)
          end
        end

        it "renders json response with success message" do
          subject
          expect(response.content_type).to eq('application/json')
          expect(response.status).to eq(201)
          json = JSON.parse(response.body)
          expect(json).to have_key('growl_message')
          expect(json).to have_key('files')
        end
      end

      context 'without passing validations' do
        it "renders json response with error message" do
          subject
          expect(response.content_type).to eq('application/json')
          expect(response.status).to eq(422)
          json = JSON.parse(response.body)
          expect(json).to have_key('growl_message')
          expect(json).to have_key('files')
        end
      end
    end

    describe '#update' do
      subject { alchemy_put :update, {id: 1, attachment: {name: ''}} }

      let(:attachment) { build_stubbed(:attachment) }

      before do
        expect(Attachment).to receive(:find).and_return(attachment)
      end

      context 'with passing validations' do
        before do
          expect(attachment).to receive(:update_attributes).and_return(true)
        end

        it "redirects to index path" do
          is_expected.to redirect_to admin_attachments_path
        end
      end

      context 'with failing validations' do
        before do
          expect(attachment).to receive(:update_attributes).and_return(false)
          expect(attachment).to receive(:errors).and_return double(empty?: false)
        end

        it "renders edit form" do
          is_expected.to render_template(:edit)
        end
      end
    end

    describe '#destroy' do
      let(:attachment) { build_stubbed(:attachment) }

      before do
        expect(Attachment).to receive(:find).and_return(attachment)
      end

      it "destroys the attachment and sets and success message" do
        expect(attachment).to receive(:destroy)
        alchemy_xhr :delete, :destroy, id: 1
        expect(assigns(:attachment)).to eq(attachment)
        expect(assigns(:url)).not_to be_blank
        expect(flash[:notice]).not_to be_blank
      end
    end

    describe "#download" do
      before do
        expect(Attachment).to receive(:find).with("#{attachment.id}").and_return(attachment)
        allow(controller).to receive(:render).and_return(nil)
      end

      it "should assign @attachment with Attachment found by id" do
        alchemy_get :download, id: attachment.id
        expect(assigns(:attachment)).to eq(attachment)
      end

      it "should send the data to the browser" do
        expect(controller).to receive(:send_data)
        alchemy_get :download, id: attachment.id
      end
    end
  end
end
