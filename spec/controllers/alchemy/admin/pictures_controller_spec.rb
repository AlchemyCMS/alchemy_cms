# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples :redirecting_to_picture_library do
  let(:params) do
    {
      filter: "latest",
      page: 2,
      q: { name_or_image_file_name_cont: "kitten" },
      size: "small",
      tagged_with: "cat",
    }
  end

  it "redirects to index keeping all query, filter and page params" do
    is_expected.to redirect_to admin_pictures_path(params)
  end
end

module Alchemy
  describe Admin::PicturesController do
    routes { Alchemy::Engine.routes }

    before do
      authorize_user(:as_admin)
    end

    describe "#index" do
      context "with search params" do
        let!(:picture_1) { create(:alchemy_picture, name: "cute kitten") }
        let!(:picture_2) { create(:alchemy_picture, name: "nice beach") }

        it "assigns @pictures with filtered pictures" do
          get :index, params: { q: { name_or_image_file_name_cont: "kitten" } }
          expect(assigns(:pictures)).to include(picture_1)
          expect(assigns(:pictures)).to_not include(picture_2)
        end
      end

      context "with filter params" do
        let!(:picture_1) { create(:alchemy_picture) }
        let!(:picture_2) { create(:alchemy_picture, tag_list: %w(kitten)) }

        it "assigns @pictures with filtered pictures" do
          get :index, params: { filter: "without_tag" }
          expect(assigns(:pictures)).to include(picture_1)
          expect(assigns(:pictures)).to_not include(picture_2)
        end
      end

      context "with tag params" do
        let!(:picture_1) { create(:alchemy_picture, tag_list: %w(water)) }
        let!(:picture_2) { create(:alchemy_picture, tag_list: %w(kitten)) }
        let!(:picture_3) { create(:alchemy_picture, tag_list: %w(water nature)) }

        it "assigns @pictures with filtered pictures" do
          get :index, params: { tagged_with: "water" }
          expect(assigns(:pictures)).to include(picture_1)
          expect(assigns(:pictures)).to_not include(picture_2)
          expect(assigns(:pictures)).to include(picture_3)
        end
      end

      context "with multiple tag params" do
        let!(:picture_1) { create(:alchemy_picture, tag_list: %w(water)) }
        let!(:picture_2) { create(:alchemy_picture, tag_list: %w(water nature)) }

        it "assigns @pictures with filtered pictures" do
          get :index, params: { tagged_with: "water,nature" }
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
          get :index, params: { size: "large" }
          expect(assigns(:size)).to eq("large")
          expect(session[:alchemy_pictures_size]).to eq("large")
        end
      end

      context "when params[:form_field_id]" do
        context "is set" do
          it "for html requests it renders the archive_overlay partial" do
            get :index, params: { form_field_id: "contents_1_picture_id" }
            expect(response).to render_template(partial: "_archive_overlay")
          end

          it "for ajax requests it renders the archive_overlay template" do
            get :index, params: { form_field_id: "contents_1_picture_id" }, xhr: true
            expect(response).to render_template(:archive_overlay)
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

      let(:params) { { picture: { name: "" } } }
      let(:picture) { mock_model("Picture", humanized_name: "Cute kittens", to_jq_upload: {}) }

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
          expect(json).to have_key("growl_message")
          expect(json).to have_key("files")
        end
      end

      context "with failing validations" do
        it_behaves_like "having a json uploader error message"
      end
    end

    describe "#show" do
      let(:picture) { create(:alchemy_picture, name: "kitten") }

      it "assigns @picture" do
        get :show, params: { id: picture.id }
        expect(assigns(:picture).id).to eq(picture.id)
      end

      context "with assignments" do
        let!(:page) { create(:alchemy_page) }
        let!(:element) { create(:alchemy_element, page: page) }
        let!(:content) { create(:alchemy_content, element: element) }
        let!(:essence) { create(:alchemy_essence_picture, content: content, picture: picture) }

        it "assigns all essence pictures having an assignment to @assignments" do
          get :show, params: { id: picture.id }
          expect(assigns(:assignments)).to eq([essence])
        end
      end

      context "with previous picture existing" do
        let!(:previous) { create(:alchemy_picture, name: "abraham") }

        it "assigns @previous to previous picture" do
          get :show, params: { id: picture.id }
          expect(assigns(:previous).id).to eq(previous.id)
        end
      end

      context "with next picture existing" do
        let!(:next_picture) { create(:alchemy_picture, name: "zebra") }

        it "assigns @next to next picture" do
          get :show, params: { id: picture.id }
          expect(assigns(:next).id).to eq(next_picture.id)
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
        put :update, params: { id: 1, picture: { name: "" } }, xhr: true
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
      subject { delete :delete_multiple, params: { picture_ids: picture_ids } }

      it_behaves_like :redirecting_to_picture_library do
        let(:subject) do
          delete :delete_multiple, params: {
                                     picture_ids: %w(1 2),
                                   }.merge(params)
        end
      end

      let(:deletable_picture) do
        mock_model("Picture", name: "pic of the pig", deletable?: true)
      end

      let(:not_deletable_picture) do
        mock_model("Picture", name: "pic of the chick", deletable?: false)
      end

      context "no picture_ids given" do
        let(:picture_ids) { "" }

        it "should give a warning about not deleting any pictures" do
          subject
          expect(flash[:warn]).to match("Could not delete Pictures")
        end
      end

      context "picture_ids given" do
        context "all are deletable" do
          let(:picture_ids) { deletable_picture.id.to_s }

          before do
            allow(Picture).to receive(:find).and_return([deletable_picture])
          end

          it "should delete the pictures give a notice about deleting them" do
            subject
            expect(flash[:notice]).to match("successfully")
          end
        end

        context "deletable and not deletable" do
          let(:picture_ids) { "#{deletable_picture.id},#{not_deletable_picture.id}" }

          before do
            allow(Picture).to receive(:find).and_return([deletable_picture, not_deletable_picture])
          end

          it "should give a warning for the non deletable pictures and delete the others" do
            expect(deletable_picture).to receive(:destroy)
            subject
            expect(flash[:warn]).to match("could not be deleted")
          end
        end

        context "with error happening" do
          let(:picture_ids) { deletable_picture.id.to_s }

          before do
            expect(Picture).to receive(:find).and_raise("yada")
          end

          it "sets error message" do
            subject
            expect(flash[:error]).not_to be_blank
          end

          it "redirects to index" do
            subject
            expect(response).to redirect_to admin_pictures_path
          end
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
        delete :destroy, params: { id: picture.id }
        expect(assigns(:picture)).to eq(picture)
        expect(flash[:notice]).not_to be_blank
      end

      context "if an error happens" do
        before do
          expect(picture).to receive(:destroy).and_raise("yada")
        end

        it "shows error notice" do
          delete :destroy, params: { id: picture.id }
          expect(flash[:error]).not_to be_blank
        end

        it "redirects to index" do
          delete :destroy, params: { id: picture.id }
          expect(response).to redirect_to admin_pictures_path
        end
      end

      it_behaves_like :redirecting_to_picture_library do
        let(:subject) { delete :destroy, params: { id: picture.id }.merge(params) }
      end
    end

    describe "#items_per_page" do
      subject { controller.send(:items_per_page) }

      before do
        controller.instance_variable_set(:@size, params[:size] || "medium")
        expect(controller).to receive(:params).at_least(:once) { params }
      end

      context "in overlay" do
        let(:params) { { form_field_id: "contents_1_picture_id", size: size } }

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
        let(:params) { { size: size } }

        context "with params[:size] set to medium" do
          let(:size) { "medium" }

          it { is_expected.to eq(20) }

          context "with cookie set" do
            before do
              @request.cookies[:alchemy_pictures_per_page] = 2
            end

            it { is_expected.to eq(2) }

            context "with params[:per_page] given" do
              let(:params) { { per_page: 8, size: size } }

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
        put :assign, params: { form_field_id: "contents_1_picture_id", id: picture.id }, xhr: true
        expect(assigns(:assignable_id)).to eq(picture.id.to_s)
        expect(assigns(:form_field_id)).to eq("contents_1_picture_id")
        expect(assigns(:picture).id).to eq(picture.id)
      end
    end
  end
end
