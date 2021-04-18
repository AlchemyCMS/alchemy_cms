# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Admin::AttachmentsController do
    routes { Alchemy::Engine.routes }

    let(:attachment) { build_stubbed(:alchemy_attachment) }

    let(:file) do
      fixture_file_upload(
        File.expand_path("../../../fixtures/500x500.png", __dir__),
        "image/png",
      )
    end

    before do
      authorize_user(:as_admin)
    end

    describe "#index" do
      it "should always paginate the records" do
        expect_any_instance_of(ActiveRecord::Relation).to receive(:page).and_call_original
        get :index
      end

      context "when params[:tagged_with] is set" do
        it "should filter the records by tags" do
          expect(Attachment).to receive(:tagged_with).and_return(Attachment.all)
          get :index, params: { tagged_with: "pdf" }
        end
      end

      context "when params[:form_field_id]" do
        context "is set" do
          it "it renders the archive_overlay partial" do
            get :index, params: { form_field_id: "contents_1_attachment_id" }
            expect(response).to render_template(partial: "_archive_overlay")
            expect(assigns(:form_field_id)).to eq("contents_1_attachment_id")
          end
        end

        context "is not set" do
          it "should render the default index view" do
            get :index
            expect(response).to render_template(:index)
          end
        end
      end

      describe "file_type filter" do
        let!(:png) { create(:alchemy_attachment) }

        let!(:jpg) do
          create :alchemy_attachment,
            file: File.new(File.expand_path("../../../fixtures/image3.jpeg", __dir__))
        end

        context "with params[:file_type]" do
          it "loads only attachments with matching content type" do
            get :index, params: { file_type: "image/jpeg" }
            expect(assigns(:attachments).to_a).to eq([jpg])
            expect(assigns(:attachments).to_a).to_not eq([png])
          end
        end
      end
    end

    describe "#show" do
      before do
        expect(Attachment).to receive(:find).and_return(attachment)
      end

      it "renders the show template" do
        get :show, params: { id: attachment.id }
        expect(response).to render_template(:show)
      end
    end

    describe "#create" do
      subject { post :create, params: params }

      context "with passing validations" do
        let(:params) { { attachment: { file: file } } }

        it "renders json response with success message" do
          subject
          expect(response.media_type).to eq("application/json")
          expect(response.status).to eq(201)
          json = JSON.parse(response.body)
          expect(json).to have_key("growl_message")
          expect(json).to have_key("files")
        end
      end

      context "with failing validations" do
        include_context "with invalid file"

        let(:params) { { attachment: { file: invalid_file } } }

        it_behaves_like "having a json uploader error message"
      end
    end

    describe "#update" do
      let(:params) do
        {
          id: attachment.id, attachment: { name: "" },
        }
      end

      subject do
        put :update, params: params
      end

      let!(:attachment) { create(:alchemy_attachment) }

      context "when file is passed" do
        let(:file) do
          fixture_file_upload(
            File.expand_path("../../../fixtures/image2.PNG", __dir__),
            "image/png",
          )
        end

        context "with passing validations" do
          let(:params) do
            {
              id: attachment.id, attachment: { file: file },
            }
          end

          it "renders json response with success message" do
            subject
            expect(response.media_type).to eq("application/json")
            expect(response.status).to eq(202)
            json = JSON.parse(response.body)
            expect(json).to have_key("growl_message")
            expect(json).to have_key("files")
          end

          it "replaces the file" do
            expect { subject }.to change { attachment.reload.file_uid }
          end
        end
      end

      context "with passing validations" do
        it "redirects to index path" do
          is_expected.to redirect_to admin_attachments_path
        end

        context "with search params" do
          let(:search_filter_params) do
            {
              q: { name_or_file_name_cont: "kitten" },
              tagged_with: "cute",
              file_type: "pdf",
              page: 2,
            }
          end

          subject do
            put :update, params: {
                           id: attachment.id, attachment: { name: "" },
                         }.merge(search_filter_params)
          end

          it "passes them along" do
            is_expected.to redirect_to admin_attachments_path(search_filter_params)
          end
        end
      end

      context "with failing validations" do
        include_context "with invalid file"

        it "renders edit form" do
          is_expected.to render_template(:edit)
        end
      end
    end

    describe "#destroy" do
      before do
        expect(Attachment).to receive(:find).and_return(attachment)
      end

      it "destroys the attachment and sets a success message" do
        expect(attachment).to receive(:destroy)
        delete :destroy, params: { id: 1 }, xhr: true
        expect(assigns(:attachment)).to eq(attachment)
        expect(assigns(:url)).not_to be_blank
        expect(flash[:notice]).not_to be_blank
      end

      context "with search params" do
        let(:search_filter_params) do
          {
            q: { name_or_file_name_cont: "kitten" },
            tagged_with: "cute",
            file_type: "pdf",
            page: 2,
          }
        end

        it "passes them along" do
          expect(attachment).to receive(:destroy) { true }
          delete :destroy, params: { id: 1 }.merge(search_filter_params), xhr: true
          expect(assigns(:url)).to eq admin_attachments_url(search_filter_params.merge(host: "test.host"))
        end
      end
    end

    describe "#download" do
      before do
        expect(Attachment).to receive(:find).and_return(attachment)
      end

      it "sends the file as download" do
        get :download, params: { id: attachment.id }
        expect(response.headers["Content-Disposition"]).to match(/attachment/)
      end
    end

    describe "#assign" do
      let(:attachment) { create(:alchemy_attachment) }

      it "assigns a assignable_id" do
        put :assign, params: { form_field_id: "contents_1_attachment_id", id: attachment.id }, xhr: true
        expect(assigns(:assignable_id)).to eq(attachment.id.to_s)
        expect(assigns(:form_field_id)).to eq("contents_1_attachment_id")
      end
    end
  end
end
