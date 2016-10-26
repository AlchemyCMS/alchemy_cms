require 'spec_helper'

module Alchemy
  describe Admin::AttachmentsController do
    let(:attachment) { build_stubbed(:alchemy_attachment) }

    let(:file) do
      fixture_file_upload(
        File.expand_path('../../../../fixtures/500x500.png', __FILE__),
        'image/png'
      )
    end

    before do
      authorize_user(:as_admin)
    end

    describe "#index" do
      it "should always paginate the records" do
        expect_any_instance_of(ActiveRecord::Relation).to receive(:page).and_call_original
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

      describe 'file_type filter' do
        let!(:png) { create(:alchemy_attachment) }

        let!(:jpg) do
          create :alchemy_attachment,
            file: File.new(File.expand_path('../../../../fixtures/image3.jpeg', __FILE__))
        end

        context 'with params[:file_type]' do
          it 'loads only attachments with matching content type' do
            alchemy_get :index, file_type: 'image/jpeg'
            expect(assigns(:attachments).to_a).to eq([jpg])
            expect(assigns(:attachments).to_a).to_not eq([png])
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

    describe '#create' do
      subject { alchemy_post :create, params }

      context 'with passing validations' do
        let(:params) { {attachment: {file: file}} }

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
        let(:params) { {attachment: {file: nil}} }

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
      let(:params) do
        {
          id: attachment.id, attachment: {name: ''}
        }
      end

      subject do
        alchemy_put :update, params
      end

      let(:attachment) { create(:alchemy_attachment) }

      context "when file is passed" do
        let(:file) do
          fixture_file_upload(
            File.expand_path('../../../../fixtures/image2.PNG', __FILE__),
            'image/png'
          )
        end

        context 'with passing validations' do
          let(:params) do
            {
              id: attachment.id, attachment: {file: file}
            }
          end

          it "renders json response with success message" do
            subject
            expect(response.content_type).to eq('application/json')
            expect(response.status).to eq(202)
            json = JSON.parse(response.body)
            expect(json).to have_key('growl_message')
            expect(json).to have_key('files')
          end

          it "replaces the file" do
            expect { subject }.to change { attachment.reload.file_uid }
          end
        end
      end

      context 'with passing validations' do
        it "redirects to index path" do
          is_expected.to redirect_to admin_attachments_path
        end

        context 'with search params' do
          let(:search_params) do
            {
              q: {name_cont: 'kitten'},
              per_page: 20,
              page: 2
            }
          end

          subject do
            alchemy_put :update, {
              id: attachment.id, attachment: {name: ''}
            }.merge(search_params)
          end

          it "passes them along" do
            is_expected.to redirect_to admin_attachments_path(search_params)
          end
        end
      end

      context 'with failing validations' do
        let(:params) do
          {
            id: attachment.id, attachment: {file: nil}
          }
        end

        it "renders edit form" do
          is_expected.to render_template(:edit)
        end
      end
    end

    describe '#destroy' do
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
        expect(Attachment).to receive(:find).with(attachment.id.to_s).and_return(attachment)
        allow(controller).to receive(:render).and_return(nil)
      end

      it "should assign @attachment with Attachment found by id" do
        alchemy_get :download, id: attachment.id
        expect(assigns(:attachment)).to eq(attachment)
      end

      it "should send the data to the browser" do
        expect(controller).to receive(:send_file)
        alchemy_get :download, id: attachment.id
      end
    end
  end
end
