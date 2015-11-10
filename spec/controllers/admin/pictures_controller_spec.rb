require 'spec_helper'

module Alchemy
  describe Admin::PicturesController do

    before do
      authorize_user(:as_admin)
    end

    describe '#index' do
      context 'with search params' do
        let!(:picture_1) { create(:alchemy_picture, name: 'cute kitten') }
        let!(:picture_2) { create(:alchemy_picture, name: 'nice beach') }

        it 'assigns @pictures with filtered pictures' do
          alchemy_get :index, q: {name_cont: 'kitten'}
          expect(assigns(:pictures)).to include(picture_1)
          expect(assigns(:pictures)).to_not include(picture_2)
        end
      end

      context 'with filter params' do
        let!(:picture_1) { create(:alchemy_picture) }
        let!(:picture_2) { create(:alchemy_picture, tag_list: %w(kitten)) }

        it 'assigns @pictures with filtered pictures' do
          alchemy_get :index, filter: 'without_tag'
          expect(assigns(:pictures)).to include(picture_1)
          expect(assigns(:pictures)).to_not include(picture_2)
        end
      end

      context 'with tag params' do
        let!(:picture_1) { create(:alchemy_picture, tag_list: %w(water)) }
        let!(:picture_2) { create(:alchemy_picture, tag_list: %w(kitten)) }

        it 'assigns @pictures with filtered pictures' do
          alchemy_get :index, tagged_with: 'water'
          expect(assigns(:pictures)).to include(picture_1)
          expect(assigns(:pictures)).to_not include(picture_2)
        end
      end

      it 'assigns @size to default value' do
        alchemy_get :index
        expect(assigns(:size)).to eq('medium')
      end

      context "with params[:size] set to 'large'" do
        it 'assigns @size to large' do
          alchemy_get :index, size: 'large'
          expect(assigns(:size)).to eq('large')
        end
      end

      context "when params[:element_id]" do
        context "is set" do
          before do
            allow(Element).to \
              receive(:find).with('1', {select: 'id'}).and_return(mock_model(Element))
          end

          it "for html requests it renders the archive_overlay partial" do
            alchemy_get :index, {element_id: 1}
            expect(response).to render_template(partial: '_archive_overlay')
          end

          it "for ajax requests it renders the archive_overlay template" do
            alchemy_xhr :get, :index, {element_id: 1}
            expect(response).to render_template(:archive_overlay)
          end
        end

        context "is not set" do
          it "should render the default index view" do
            alchemy_get :index
            expect(response).to render_template(:index)
          end
        end
      end
    end

    describe '#new' do
      subject { alchemy_get :new, params }

      let(:params) { Hash.new }

      context 'if inside of archive overlay' do
        let(:params)  { {element_id: 1, content_id: 1} }
        let(:element) { mock_model('Element') }
        let(:content) { mock_model('Content') }

        before do
          expect(Content).to receive(:select).and_return(double(find_by: content))
          expect(Element).to receive(:select).and_return(double(find_by: element))
        end

        it "assigns lots of instance variables" do
          subject
          expect(assigns(:options)).to eq({})
          expect(assigns(:while_assigning)).to be_truthy
          expect(assigns(:content)).to eq(content)
          expect(assigns(:element)).to eq(element)
          expect(assigns(:page)).to eq(1)
          expect(assigns(:per_page)).to eq(9)
        end
      end

      context 'with size param given' do
        let(:params) { {size: '200x200'} }
        before { subject }
        it { expect(assigns(:size)).to eq('200x200') }
      end

      context 'without size param given' do
        let(:params) { {size: nil} }
        before { subject }
        it { expect(assigns(:size)).to eq('medium') }
      end
    end

    describe '#create' do
      subject { alchemy_post :create, params }

      let(:params)  { {picture: {name: ''}} }
      let(:picture) { mock_model('Picture', humanized_name: 'Cute kittens', to_jq_upload: {}) }

      context 'with passing validations' do
        before do
          expect(Picture).to receive(:new).and_return(picture)
          expect(picture).to receive(:name=).and_return('Cute kittens')
          expect(picture).to receive(:name).and_return('Cute kittens')
          expect(picture).to receive(:save).and_return(true)
        end

        context 'if inside of archive overlay' do
          let(:params)  { {picture: {name: ''}, element_id: 1} }
          let(:element) { mock_model('Element') }
          let(:content) { mock_model('Content') }

          before do
            expect(Content).to receive(:select).and_return(double(find_by: content))
            expect(Element).to receive(:select).and_return(double(find_by: element))
          end

          it "assigns lots of instance variables" do
            subject
            expect(assigns(:options)).to eq({})
            expect(assigns(:while_assigning)).to be_truthy
            expect(assigns(:content)).to eq(content)
            expect(assigns(:element)).to eq(element)
            expect(assigns(:page)).to eq(1)
            expect(assigns(:per_page)).to eq(9)
          end
        end

        context 'with size param given' do
          let(:params) { {picture: {name: ''}, size: '200x200'} }
          before { subject }
          it { expect(assigns(:size)).to eq('200x200') }
        end

        context 'without size param given' do
          let(:params) { {picture: {name: ''}, size: nil} }
          before { subject }
          it { expect(assigns(:size)).to eq('medium') }
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

    describe '#show' do
      let(:picture) { create(:alchemy_picture, name: 'kitten') }

      it 'assigns @picture' do
        alchemy_get :show, id: picture.id
        expect(assigns(:picture).id).to eq(picture.id)
      end

      context 'with assignments' do
        let!(:page) { create(:alchemy_page) }
        let!(:element) { create(:alchemy_element, page: page) }
        let!(:content) { create(:alchemy_content, element: element) }
        let!(:essence) { create(:alchemy_essence_picture, content: content, picture: picture) }

        it 'assigns @pages to assignments grouped by page' do
          alchemy_get :show, id: picture.id
          expect(assigns(:pages)).to eq({page => [essence]})
        end
      end

      context 'with previous picture existing' do
        let!(:previous) { create(:alchemy_picture, name: 'abraham') }

        it 'assigns @previous to previous picture' do
          alchemy_get :show, id: picture.id
          expect(assigns(:previous).id).to eq(previous.id)
        end
      end

      context 'with next picture existing' do
        let!(:next_picture) { create(:alchemy_picture, name: 'zebra') }

        it 'assigns @next to next picture' do
          alchemy_get :show, id: picture.id
          expect(assigns(:next).id).to eq(next_picture.id)
        end
      end
    end

    describe '#edit_multiple' do
      let(:pictures) { [mock_model('Picture', tag_list: 'kitten')] }
      before { expect(Picture).to receive(:where).and_return(pictures) }

      it 'assigns pictures instance variable' do
        alchemy_get :edit_multiple
        expect(assigns(:pictures)).to eq(pictures)
      end

      it 'assigns tags instance variable' do
        alchemy_get :edit_multiple
        expect(assigns(:tags)).to include('kitten')
      end
    end

    describe '#update' do
      subject { alchemy_xhr :put, :update, {id: 1, picture: {name: ''}} }

      let(:picture) { build_stubbed(:alchemy_picture, name: 'Cute kitten') }

      before do
        expect(Picture).to receive(:find).and_return(picture)
      end

      context 'with passing validations' do
        before do
          expect(picture).to receive(:update).and_return(true)
        end

        it "sets success notice" do
          subject
          expect(assigns(:message)[:body]).to \
            eq(Alchemy::I18n.t(:picture_updated_successfully, name: picture.name))
          expect(assigns(:message)[:type]).to eq('notice')
        end
      end

      context 'with failing validations' do
        before do
          expect(picture).to receive(:update).and_return(false)
        end

        it "sets error notice" do
          subject
          expect(assigns(:message)[:body]).to eq(Alchemy::I18n.t(:picture_update_failed))
          expect(assigns(:message)[:type]).to eq('error')
        end
      end
    end

    describe '#update_multiple' do
      let(:picture)  { build_stubbed(:alchemy_picture) }
      let(:pictures) { [picture] }

      before do
        expect(Picture).to receive(:find).and_return(pictures)
        expect(picture).to receive(:save!).and_return(true)
      end

      it "loads and assigns pictures" do
        alchemy_post :update_multiple
        expect(assigns(:pictures)).to eq(pictures)
      end
    end

    describe "#delete_multiple" do
      subject { alchemy_delete :delete_multiple, picture_ids: picture_ids }

      let(:deletable_picture)     { mock_model('Picture', name: 'pic of the pig', deletable?: true) }
      let(:not_deletable_picture) { mock_model('Picture', name: 'pic of the chick', deletable?: false) }

      context "no picture_ids given" do
        let(:picture_ids) { '' }

        it "should give a warning about not deleting any pictures" do
          subject
          expect(flash[:warn]).to match('Could not delete Pictures')
        end
      end

      context "picture_ids given" do
        context "all are deletable" do
          let(:picture_ids) { "#{deletable_picture.id}" }

          before do
            allow(Picture).to receive(:find).and_return([deletable_picture])
          end

          it "should delete the pictures give a notice about deleting them" do
            subject
            expect(flash[:notice]).to match('successfully')
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
            expect(flash[:warn]).to match('could not be deleted')
          end
        end

        context 'with error happening' do
          let(:picture_ids) { "#{deletable_picture.id}" }

          before do
            expect(Picture).to receive(:find).and_raise('yada')
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

    describe '#destroy' do
      let(:picture) { build_stubbed(:alchemy_picture, name: 'Cute kitten') }

      before do
        expect(Picture).to receive(:find).and_return(picture)
      end

      it "destroys the picture and sets and success message" do
        expect(picture).to receive(:destroy)
        alchemy_delete :destroy, id: picture.id
        expect(assigns(:picture)).to eq(picture)
        expect(flash[:notice]).not_to be_blank
      end

      context 'if an error happens' do
        before do
          expect(picture).to receive(:destroy).and_raise('yada')
        end

        it "shows error notice" do
          alchemy_delete :destroy, id: picture.id
          expect(flash[:error]).not_to be_blank
        end

        it "redirects to index" do
          alchemy_delete :destroy, id: picture.id
          expect(response).to redirect_to admin_pictures_path
        end
      end
    end

    describe '#flush' do
      it "removes the complete pictures cache" do
        expect(FileUtils).to receive(:rm_rf).with(Rails.root.join('public', '', 'pictures'))
        alchemy_xhr :post, :flush
      end
    end

    describe '#pictures_per_page_for_size' do
      subject { controller.send(:pictures_per_page_for_size, size) }

      before do
        expect(controller).to receive(:in_overlay?).and_return(true)
      end

      context 'with params[:size] set to medium' do
        let(:size) { 'medium' }
        it { is_expected.to eq(9) }
      end

      context 'with params[:size] set to small' do
        let(:size) { 'small' }
        it { is_expected.to eq(25) }
      end

      context 'with params[:size] set to large' do
        let(:size) { 'large' }
        it { is_expected.to eq(4) }
      end
    end
  end
end
