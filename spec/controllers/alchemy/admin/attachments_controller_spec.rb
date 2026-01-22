# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Admin::AttachmentsController do
    shared_context "with search params" do
      let(:q) do
        if Alchemy.storage_adapter.dragonfly?
          {
            file_name_or_name_cont: "kitten",
            by_file_type: "pdf"
          }
        elsif Alchemy.storage_adapter.active_storage?
          {
            file_blob_filename_or_name_cont: "kitten",
            by_file_type: "pdf"
          }
        end
      end

      let(:search_filter_params) do
        {
          q:,
          tagged_with: "cute",
          page: 2
        }
      end
    end

    routes { Alchemy::Engine.routes }

    let(:attachment) { create(:alchemy_attachment, file: file) }

    let(:file) do
      fixture_file_upload("500x500.png")
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
          get :index, params: {tagged_with: "pdf"}
        end
      end

      context "when params[:form_field_id]" do
        context "is set" do
          it "it renders the archive_overlay partial" do
            get :index, params: {form_field_id: "element_1_ingredient_1_attachment_id"}
            expect(response).to render_template(partial: "_archive_overlay")
            expect(assigns(:form_field_id)).to eq("element_1_ingredient_1_attachment_id")
          end
        end

        context "is not set" do
          it "should render the default index view" do
            get :index
            expect(response).to render_template(:index)
          end
        end
      end

      describe "by_file_type filter" do
        let!(:png) { create(:alchemy_attachment) }

        let!(:jpg) do
          create :alchemy_attachment,
            file: fixture_file_upload("image3.jpeg")
        end

        it "loads only attachments with matching content type" do
          get :index, params: {q: {by_file_type: "image/jpeg"}}
          expect(assigns(:attachments).to_a).to eq([jpg])
          expect(assigns(:attachments).to_a).to_not eq([png])
        end

        context "with multiple content types" do
          it "loads only attachments with matching content type" do
            get :index, params: {q: {by_file_type: ["image/jpeg"]}}
            expect(assigns(:attachments).to_a).to eq([jpg])
            expect(assigns(:attachments).to_a).to_not eq([png])
          end
        end

        context "with only param" do
          it "populates by_file_type query" do
            get :index, params: {only: ["png"]}
            expect(assigns(:attachments).to_a).to eq([png])
            expect(assigns(:attachments).to_a).to_not eq([jpg])
          end
        end

        context "with only param and by_file_type query" do
          it "uses by_file_type query" do
            get :index, params: {only: ["png"], q: {by_file_type: "image/jpeg"}}
            expect(assigns(:attachments).to_a).to eq([jpg])
            expect(assigns(:attachments).to_a).to_not eq([png])
          end
        end
      end

      describe "not_file_type filter" do
        let!(:png) { create(:alchemy_attachment) }

        let!(:jpg) do
          create :alchemy_attachment,
            file: fixture_file_upload("image3.jpeg")
        end

        it "loads all but attachments with matching content type" do
          get :index, params: {q: {not_file_type: "image/jpeg"}}
          expect(assigns(:attachments).to_a).to_not eq([jpg])
          expect(assigns(:attachments).to_a).to eq([png])
        end

        context "with multiple content types" do
          it "loads all but attachments with matching content type" do
            get :index, params: {q: {not_file_type: ["image/jpeg"]}}
            expect(assigns(:attachments).to_a).to_not eq([jpg])
            expect(assigns(:attachments).to_a).to eq([png])
          end
        end

        context "with except param" do
          it "populates by_file_type query" do
            get :index, params: {except: ["jpg"]}
            expect(assigns(:attachments).to_a).to eq([png])
            expect(assigns(:attachments).to_a).to_not eq([jpg])
          end
        end

        context "with except param and by_file_type query" do
          it "uses by_file_type query" do
            get :index, params: {except: ["png"], q: {by_file_type: "image/jpeg"}}
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
        get :show, params: {id: attachment.id}
        expect(response).to render_template(:show)
      end

      context "with assignments" do
        let!(:page) { create(:alchemy_page) }
        let!(:element) { create(:alchemy_element, page: page) }
        let!(:ingredient) { create(:alchemy_ingredient_file, element: element, related_object: attachment) }

        before do
          page.publish!
        end

        it "assigns all file ingredients having an assignment to @assignments" do
          get :show, params: {id: attachment.id}
          expect(assigns(:assignments)).to eq([ingredient])
        end
      end
    end

    describe "#create" do
      subject { post :create, params: params }

      context "with passing validations" do
        let(:params) { {attachment: {file: file}} }

        it "renders json response with success message" do
          subject
          expect(response.media_type).to eq("application/json")
          expect(response.status).to eq(201)
          json = JSON.parse(response.body)
          expect(json).to have_key("message")
        end
      end

      context "with failing validations" do
        include_context "with invalid file"

        let(:params) { {attachment: {file: invalid_file}} }

        it_behaves_like "having a json uploader error message"
      end
    end

    describe "#update" do
      let(:params) do
        {
          id: attachment.id, attachment: {name: ""}
        }
      end

      subject do
        put :update, params: params
      end

      let!(:attachment) { create(:alchemy_attachment) }

      context "when file is passed" do
        let(:file) do
          fixture_file_upload("image2.PNG")
        end

        context "with passing validations" do
          let(:params) do
            {
              id: attachment.id, attachment: {file: file}
            }
          end

          it "renders json response with success message" do
            subject
            expect(response.media_type).to eq("application/json")
            expect(response.status).to eq(202)
            json = JSON.parse(response.body)
            expect(json).to have_key("message")
          end

          it "replaces the file" do
            expect { subject }.to change {
              if Alchemy.storage_adapter.dragonfly?
                attachment.reload.file_uid
              elsif Alchemy.storage_adapter.active_storage?
                attachment.reload.file_blob
              end
            }
          end
        end

        context "with failing validations" do
          include_context "with invalid file"

          let(:params) do
            {
              id: attachment.id, attachment: {file: invalid_file}
            }
          end

          it_behaves_like "having a json uploader error message"
        end
      end

      context "with passing validations" do
        it "redirects to index path" do
          is_expected.to redirect_to admin_attachments_path
        end

        context "with search params" do
          include_context "with search params"

          subject do
            put :update, params: {
              id: attachment.id, attachment: {name: ""}
            }.merge(search_filter_params)
          end

          it "passes them along" do
            is_expected.to redirect_to admin_attachments_path(search_filter_params)
          end
        end
      end
    end

    describe "#destroy" do
      before do
        expect(Attachment).to receive(:find).and_return(attachment)
      end

      it "destroys the attachment, sets a success message and redirects" do
        expect(attachment).to receive(:destroy)
        delete :destroy, params: {id: 1}
        expect(flash[:notice]).to eq("image has been deleted")
        expect(response).to redirect_to admin_attachments_path
      end

      context "with search params" do
        include_context "with search params"

        it "passes them along" do
          expect(attachment).to receive(:destroy) { true }
          delete :destroy, params: {id: 1}.merge(search_filter_params), xhr: true
          expect(response).to redirect_to admin_attachments_url(search_filter_params.merge(host: "test.host"))
        end
      end
    end

    describe "#assign" do
      let(:attachment) { create(:alchemy_attachment) }

      it "assigns a assignable_id" do
        put :assign, params: {form_field_id: "element_1_ingredient_1_attachment_id", id: attachment.id}, xhr: true
        expect(assigns(:assignable_id)).to eq(attachment.id.to_s)
        expect(assigns(:form_field_id)).to eq("element_1_ingredient_1_attachment_id")
      end
    end
  end
end
