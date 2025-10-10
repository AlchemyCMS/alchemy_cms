# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Admin::PicturesController do
    routes { Alchemy::Engine.routes }

    before do
      authorize_user(:as_admin)
    end

    let!(:language) { create(:alchemy_language) }

    let(:search_params) do
      if Alchemy.storage_adapter.dragonfly?
        {
          name_or_image_file_name_cont: "kitten",
          last_upload: true
        }
      elsif Alchemy.storage_adapter.active_storage?
        {
          name_or_image_file_blob_filename_cont: "kitten",
          last_upload: true
        }
      end
    end

    shared_examples :redirecting_to_picture_library do
      let(:params) do
        {
          page: 2,
          q: search_params,
          size: "small",
          tagged_with: "cat"
        }
      end

      it "redirects to index keeping all query, filter and page params" do
        is_expected.to redirect_to admin_pictures_path(params)
      end
    end

    describe "#index" do
      context "with search params" do
        let!(:picture_1) { create(:alchemy_picture, name: "cute kitten", upload_hash: "123") }
        let!(:picture_2) { create(:alchemy_picture, name: "nice beach", upload_hash: "123") }

        it "assigns @pictures with filtered pictures" do
          get :index, params: {q: search_params}
          expect(assigns(:pictures)).to include(picture_1)
          expect(assigns(:pictures)).to_not include(picture_2)
        end
      end

      context "with filter params" do
        let!(:picture_1) { create(:alchemy_picture) }
        let!(:picture_2) { create(:alchemy_picture, tag_list: %w[kitten]) }

        it "assigns @pictures with filtered pictures" do
          get :index, params: {q: {without_tag: true}}

          expect(assigns(:pictures)).to include(picture_1)
          expect(assigns(:pictures)).to_not include(picture_2)
        end
      end

      context "with tag params" do
        let!(:picture_1) { create(:alchemy_picture, tag_list: %w[water]) }
        let!(:picture_2) { create(:alchemy_picture, tag_list: %w[kitten]) }
        let!(:picture_3) { create(:alchemy_picture, tag_list: %w[water nature]) }

        it "assigns @pictures with filtered pictures" do
          get :index, params: {tagged_with: "water"}
          expect(assigns(:pictures)).to include(picture_1)
          expect(assigns(:pictures)).to_not include(picture_2)
          expect(assigns(:pictures)).to include(picture_3)
        end
      end

      context "with multiple tag params" do
        let!(:picture_1) { create(:alchemy_picture, tag_list: %w[water]) }
        let!(:picture_2) { create(:alchemy_picture, tag_list: %w[water nature]) }

        it "assigns @pictures with filtered pictures" do
          get :index, params: {tagged_with: "water,nature"}
          expect(assigns(:pictures)).to_not include(picture_1)
          expect(assigns(:pictures)).to include(picture_2)
        end
      end

      context "with params[:size] not set" do
        subject { get(:index) }

        context "and session pictures size not set" do
          it "sets size to default value" do
            subject
            expect(assigns(:size)).to eq("medium")
            expect(session[:alchemy_pictures_size]).to eq("medium")
          end

          context "but with pictures size set in session" do
            before do
              session[:alchemy_pictures_size] = "small"
            end

            it "sets size to that value" do
              subject
              expect(assigns(:size)).to eq("small")
              expect(session[:alchemy_pictures_size]).to eq("small")
            end
          end
        end
      end

      context "with params[:size] set to 'large'" do
        it "sets size to large" do
          get :index, params: {size: "large"}
          expect(assigns(:size)).to eq("large")
          expect(session[:alchemy_pictures_size]).to eq("large")
        end
      end

      context "when params[:form_field_id]" do
        context "is set" do
          it "it renders the archive_overlay partial" do
            get :index, params: {form_field_id: "element_1_ingredient_1_picture_id"}
            expect(response).to render_template(partial: "_archive_overlay")
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

    describe "#create" do
      subject { post :create, params: params }

      let(:params) { {picture: {name: ""}} }
      let(:picture) { mock_model("Picture", humanized_name: "Cute kittens") }

      context "with passing validations" do
        before do
          expect(Picture).to receive(:new).and_return(picture)
          expect(picture).to receive(:name=).and_return("Cute kittens")
          expect(picture).to receive(:name).and_return("Cute kittens")
          expect(picture).to receive(:save).and_return(true)
        end

        it "renders json response with success message" do
          subject
          expect(response.media_type).to eq("application/json")
          expect(response.status).to eq(201)
          json = JSON.parse(response.body)
          expect(json).to have_key("message")
        end
      end

      context "with failing validations" do
        it_behaves_like "having a json uploader error message"
      end
    end

    describe "#show" do
      let!(:picture) { create(:alchemy_picture, name: "kitten") }

      it "assigns @picture" do
        get :show, params: {id: picture.id}
        expect(assigns(:picture).id).to eq(picture.id)
      end

      context "with assignments" do
        let!(:page) { create(:alchemy_page) }
        let!(:element) { create(:alchemy_element, page: page) }
        let!(:ingredient) { create(:alchemy_ingredient_picture, element: element, related_object: picture) }

        it "assigns all picture ingredients having an assignment to @assignments" do
          get :show, params: {id: picture.id}
          expect(assigns(:assignments)).to eq([ingredient])
        end
      end

      context "with previous picture existing" do
        let!(:previous) { create(:alchemy_picture, name: "abraham") }

        it "assigns @previous to previous picture" do
          get :show, params: {id: :previous, picture_index: 2}
          expect(assigns(:previous)).to eq(1)
        end
      end

      context "with next picture existing" do
        let!(:next_picture) { create(:alchemy_picture, name: "zebra") }

        it "assigns @next to next picture" do
          get :show, params: {id: :next, picture_index: 1}
          expect(assigns(:next)).to eq(2)
        end
      end
    end

    describe "#edit_multiple" do
      let(:pictures) { [mock_model("Picture", tag_list: "kitten")] }
      before { expect(Picture).to receive(:where).and_return(pictures) }

      it "assigns pictures instance variable" do
        get :edit_multiple
        expect(assigns(:pictures)).to eq(pictures)
      end

      it "assigns tags instance variable" do
        get :edit_multiple
        expect(assigns(:tags)).to include("kitten")
      end
    end

    describe "#update" do
      subject do
        put :update, params: {id: 1, picture: {name: ""}}, xhr: true
      end

      let(:picture) { build_stubbed(:alchemy_picture, name: "Cute kitten") }

      before do
        expect(Picture).to receive(:find).and_return(picture)
      end

      context "with passing validations" do
        before do
          expect(picture).to receive(:update).and_return(true)
        end

        it "sets success notice" do
          subject
          expect(assigns(:message)[:body]).to \
            eq(Alchemy.t(:picture_updated_successfully, name: picture.name))
          expect(assigns(:message)[:type]).to eq("notice")
        end
      end

      context "with failing validations" do
        before do
          expect(picture).to receive(:update).and_return(false)
        end

        it "sets error notice" do
          subject
          expect(assigns(:message)[:body]).to eq(Alchemy.t(:picture_update_failed))
          expect(assigns(:message)[:type]).to eq("error")
        end

        it "sets 422 status" do
          expect(subject.status).to eq 422
        end
      end

      context "update description" do
        let(:picture) { create(:alchemy_picture) }

        subject do
          put :update, params: {
            id: 1,
            picture: {
              name: "",
              descriptions_attributes: {
                0 => {
                  text: "foo bar",
                  language_id: language.id
                }
              }
            }
          }, xhr: true
        end

        it "sets the description" do
          subject
          expect(picture.description_for(language)).to eq("foo bar")
        end
      end
    end

    describe "#update_multiple" do
      let(:picture) { build_stubbed(:alchemy_picture) }
      let(:pictures) { [picture] }

      before do
        expect(Picture).to receive(:find).and_return(pictures)
        expect(picture).to receive(:save!).and_return(true)
      end

      it "loads and assigns pictures" do
        post :update_multiple
        expect(assigns(:pictures)).to eq(pictures)
      end

      it_behaves_like :redirecting_to_picture_library do
        let(:subject) { post(:update_multiple, params: params) }
      end
    end

    describe "#delete_multiple" do
      subject do
        delete :delete_multiple, params: {picture_ids: picture_ids}
      end

      it_behaves_like :redirecting_to_picture_library do
        let(:subject) do
          delete :delete_multiple, params: {
            picture_ids: %w[1 2]
          }.merge(params)
        end
      end

      let(:picture) do
        build_stubbed(:alchemy_picture)
      end

      context "no picture_ids given" do
        let(:picture_ids) { "" }

        it "should give a warning about not deleting any pictures" do
          subject
          expect(flash[:warn]).to match("Could not delete Pictures")
        end
      end

      context "picture_ids given" do
        let(:picture_ids) { [picture.id] }

        it "enqueues the picture delete job" do
          subject
          expect(DeletePictureJob).to have_been_enqueued.with(picture.id.to_s)
          expect(flash[:notice]).to match("Pictures will be deleted now")
        end
      end
    end

    describe "#destroy" do
      let(:picture) { build_stubbed(:alchemy_picture, name: "Cute kitten") }

      before do
        expect(Picture).to receive(:find).and_return(picture)
      end

      it "destroys the picture and sets and success message" do
        expect(picture).to receive(:destroy)
        delete :destroy, params: {id: picture.id}
        expect(assigns(:picture)).to eq(picture)
        expect(flash[:notice]).not_to be_blank
      end

      context "if an error happens" do
        before do
          expect(picture).to receive(:destroy).and_raise("yada")
        end

        it "shows error notice" do
          delete :destroy, params: {id: picture.id}
          expect(flash[:error]).not_to be_blank
        end

        it "redirects to index" do
          delete :destroy, params: {id: picture.id}
          expect(response).to redirect_to admin_pictures_path
        end
      end

      it_behaves_like :redirecting_to_picture_library do
        let(:subject) { delete :destroy, params: {id: picture.id}.merge(params) }
      end
    end

    describe "#items_per_page" do
      subject { controller.send(:items_per_page) }

      before do
        controller.instance_variable_set(:@size, params[:size] || "medium")
        expect(controller).to receive(:params).at_least(:once) { params }
      end

      context "in overlay" do
        let(:params) { {form_field_id: "element_1_ingredient_1_picture_id", size: size} }

        context "with params[:size] set to medium" do
          let(:size) { "medium" }

          it { is_expected.to eq(9) }
        end

        context "with params[:size] set to small" do
          let(:size) { "small" }

          it { is_expected.to eq(25) }
        end

        context "with params[:size] set to large" do
          let(:size) { "large" }

          it { is_expected.to eq(4) }
        end
      end

      context "in archive" do
        let(:params) { {size: size} }

        context "with params[:size] set to medium" do
          let(:size) { "medium" }

          it { is_expected.to eq(20) }

          context "with cookie set" do
            before do
              @request.cookies[:alchemy_pictures_per_page] = 2
            end

            it { is_expected.to eq(2) }

            context "with params[:per_page] given" do
              let(:params) { {per_page: 8, size: size} }

              it { is_expected.to eq(8) }
            end
          end
        end

        context "with params[:size] set to small" do
          let(:size) { "small" }

          it { is_expected.to eq(60) }
        end

        context "with params[:size] set to large" do
          let(:size) { "large" }

          it { is_expected.to eq(12) }
        end
      end
    end

    describe "#assign" do
      let(:picture) { create(:alchemy_picture) }

      it "assigns a assignable_id" do
        put :assign, params: {form_field_id: "element_1_ingredient_1_picture_id", id: picture.id}, xhr: true
        expect(assigns(:assignable_id)).to eq(picture.id.to_s)
        expect(assigns(:form_field_id)).to eq("element_1_ingredient_1_picture_id")
        expect(assigns(:picture).id).to eq(picture.id)
      end
    end
  end
end
