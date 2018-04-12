# frozen_string_literal: true

require 'spec_helper'

module Alchemy
  describe Admin::EssencePicturesController do
    routes { Alchemy::Engine.routes }

    before { authorize_user(:as_admin) }

    let(:essence) { EssencePicture.new }
    let(:content) { Content.new }
    let(:picture) { Picture.new }

    describe '#edit' do
      before do
        expect(EssencePicture).to receive(:find).and_return(essence)
        expect(Content).to receive(:find).and_return(content)
      end

      it 'should assign @essence_picture and @content instance variables' do
        post :edit, params: {id: 1, content_id: 1}
        expect(assigns(:essence_picture)).to be_a(EssencePicture)
        expect(assigns(:content)).to be_a(Content)
      end
    end

    describe '#crop' do
      before do
        expect(EssencePicture).to receive(:find).and_return(essence)
      end

      context 'with no picture assigned' do
        before do
          expect(essence).to receive(:picture).at_least(:once).and_return(nil)
        end

        it "renders error message" do
          get :crop, params: {id: 1}
          expect(assigns(:no_image_notice)).to eq(Alchemy.t(:no_image_for_cropper_found))
        end
      end

      context 'with picture assigned' do
        let(:default_mask) do
          {
            x1: 0,
            y1: 0,
            x2: 300,
            y2: 250
          }
        end

        before do
          picture.image_file_width = 300
          picture.image_file_height = 250
          expect(essence).to receive(:picture).at_least(:once).and_return(picture)
        end

        context 'with no render_size present in essence' do
          before do
            expect(essence).to receive(:render_size).at_least(:once).and_return(nil)
          end

          context 'with sizes in params' do
            it "sets sizes to given values" do
              get :crop, params: {id: 1, options: {size: '300x250'}}
              expect(assigns(:min_size)).to eq({ width: 300, height: 250 })
            end
          end

          context 'with no sizes in params' do
            it "sets sizes to zero" do
              get :crop, params: {id: 1}
              expect(assigns(:min_size)).to eq({ width: 0, height: 0 })
            end
          end
        end

        context 'with render_size present in essence' do
          it "sets sizes from these values" do
            expect(essence).to receive(:render_size).at_least(:once).and_return('30x25')

            get :crop, params: {id: 1}
            expect(assigns(:min_size)).to eq({ width: 30, height: 25 })
          end

          context 'when width or height is not fixed' do
            it 'infers the height from the image file preserving the aspect ratio' do
              expect(essence).to receive(:render_size).at_least(:once).and_return('30x')

              get :crop, params: {id: 1}
              expect(assigns(:min_size)).to eq({ width: 30, height: 0})
            end

            it 'does not infer the height from the image file preserving the aspect ratio' do
              expect(essence).to receive(:render_size).at_least(:once).and_return('x25')

              get :crop, params: {id: 1, options: { fixed_ratio: "2"}}
              expect(assigns(:min_size)).to eq({ width: 50, height: 25 })
            end
          end

          context 'when width or height is not fixed and an aspect ratio is given' do
            it 'width is given, it infers the height from width and ratio' do
              expect(essence).to receive(:render_size).at_least(:once).and_return('30x')

              get :crop, params: {id: 1, options: { fixed_ratio: "0.5" }}
              expect(assigns(:min_size)).to eq({ width: 30, height: 60 })
            end

            it 'infers the height from the image file preserving the aspect ratio' do
              expect(essence).to receive(:render_size).at_least(:once).and_return('x25')

              get :crop, params: {id: 1}
              expect(assigns(:min_size)).to eq({ width: 0, height: 25})
            end
          end
        end

        context 'no crop sizes present in essence' do
          before do
            expect(essence).to receive(:crop_from).and_return(nil)
            allow(essence).to receive(:crop_size).and_return(nil)
          end

          it "assigns default mask boxes" do
            get :crop, params: {id: 1}
            expect(assigns(:initial_box)).to eq(default_mask)
            expect(assigns(:default_box)).to eq(default_mask)
          end
        end

        context 'crop sizes present in essence' do
          let(:mask) { {'x1' => '0', 'y1' => '0', 'x2' => '120', 'y2' => '160'} }

          before do
            allow(essence).to receive(:crop_from).and_return('0x0')
            allow(essence).to receive(:crop_size).and_return('120x160')
          end

          it "assigns cropping boxes" do
            expect(essence).to receive(:cropping_mask).and_return(mask)
            get :crop, params: {id: 1}
            expect(assigns(:initial_box)).to eq(mask)
            expect(assigns(:default_box)).to eq(default_mask)
          end
        end

        context 'with fixed_ratio set to false' do
          it "sets ratio to false" do
            get :crop, params: {id: 1, options: {fixed_ratio: false}}
            expect(assigns(:ratio)).to eq(false)
          end
        end

        context 'with fixed_ratio set to a non float string' do
          it "doesn't set a fixed ratio" do
            get :crop, params: {id: 1, options: {fixed_ratio: '123,45'}}
            expect(assigns(:ratio)).to eq(false)
          end
        end

        context 'with no fixed_ratio set in params' do
          it "sets a fixed ratio from sizes" do
            get :crop, params: {id: 1, options: {size: '80x60'}}
            expect(assigns(:ratio)).to eq(80.0 / 60.0)
          end
        end
      end
    end

    describe '#update' do
      before do
        expect(EssencePicture).to receive(:find).and_return(essence)
        expect(Content).to receive(:find).and_return(content)
      end

      let(:attributes) do
        {
          render_size: '1x1',
          alt_tag: 'Alt Tag',
          caption: 'Caption',
          css_class: 'CSS Class',
          title: 'Title'
        }
      end

      it "updates the essence attributes" do
        expect(essence).to receive(:update).and_return(true)
        put :update, params: {id: 1, essence_picture: attributes}, xhr: true
      end

      it "saves the cropping mask" do
        expect(essence).to receive(:update).and_return(true)
        put :update, params: {
          id: 1,
          essence_picture: {
            render_size: '1x1',
            crop_from: '0x0',
            crop_size: '100x100'
          }
        }, xhr: true
      end
    end

    describe '#assign' do
      let(:content) { create(:alchemy_content) }

      before do
        expect(Content).to receive(:find).and_return(content)
        expect(content).to receive(:essence).at_least(:once).and_return(essence)
        expect(Picture).to receive(:find_by).and_return(picture)
      end

      it "should assign a Picture" do
        put :assign, params: {content_id: '1', picture_id: '1'}, xhr: true
        expect(assigns(:content).essence.picture).to eq(picture)
      end

      it "updates the content timestamp" do
        content.update_column(:updated_at, 3.days.ago)
        expect {
          put :assign, params: {content_id: '1', picture_id: '1'}, xhr: true
        }.to change(content, :updated_at)
      end
    end
  end
end
