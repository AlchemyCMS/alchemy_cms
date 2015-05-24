require 'spec_helper'

# Fixes missing method tempfile error
class Rack::Test::UploadedFile
  attr_reader :tempfile
end

module Alchemy
  describe PicturesController do

    let(:public_page)        { create(:public_page, restricted: false) }
    let(:restricted_page)    { create(:public_page, restricted: true) }
    let(:element)            { create(:element, page: public_page, name: 'bild', create_contents_after_create: true) }
    let(:restricted_element) { create(:element, page: restricted_page, name: 'bild', create_contents_after_create: true) }
    let(:picture)            { create(:picture, image_file: fixture_file_upload(File.expand_path('../../fixtures/image.png', __FILE__), 'image/png')) }

    describe '#zoom' do
      let(:picture) do
        create(:picture, image_file: fixture_file_upload(File.expand_path('../../fixtures/80x60.png', __FILE__), 'image/png'))
      end

      it "renders the original image without any resizing" do
        alchemy_get :zoom, id: picture.id, name: picture.urlname, format: :png, sh: picture.security_token
        expect(response.body[0x10..0x18].unpack('NN')).to eq([80, 60])
      end

      context "Requesting a picture that is assigned with restricted pages only" do
        before do
          essence = restricted_element.contents.where(name: 'image').first.essence
          essence.picture_id = picture.id
          essence.save
        end

        context "as guest user" do
          it "should not render the picture, but redirect to login path" do
            alchemy_get :zoom, id: picture.id, name: picture.urlname, format: :png, sh: picture.security_token
            expect(response.status).to eq(302)
            expect(response).to redirect_to(Alchemy.login_path)
          end
        end

        context "as member user" do
          before do
            authorize_user(build(:alchemy_dummy_user))
          end

          it "should render the picture" do
            alchemy_get :zoom, id: picture.id, name: picture.urlname, format: :png, sh: picture.security_token
            expect(response.status).to eq(200)
          end
        end
      end
    end

    describe '#show' do
      it "skips the session cookie" do
        expect {
          alchemy_get :show, id: picture.id, name: picture.urlname, format: :png, sh: picture.security_token
        }.to change {
          request.session_options.fetch(:skip) { false }
        }.to(true)
      end

      context "Requesting a picture with tempared security token" do
        it "should render status 400" do
          alchemy_get :show, id: picture.id, name: picture.urlname, format: :png, sh: '14m4b4dh4ck3r'
          expect(response.status).to eq(400)
        end
      end

      context "Requesting a picture with another format then the original image" do
        it "should convert the picture format" do
          alchemy_get :show, id: picture.id, name: picture.urlname, format: :jpeg, sh: picture.security_token
          expect(response.content_type).to eq('image/jpeg')
        end
      end

      context "Requesting a picture with not allowed format" do
        it "should raise error" do
          expect {
            alchemy_get :show, id: picture.id, name: picture.urlname, format: :wim, sh: picture.security_token
          }.to raise_error(ActionController::UnknownFormat)
        end
      end

      context "Requesting a picture that has no image file attached" do
        before do
          expect(picture).to receive(:image_file).and_return(nil)
          expect(Picture).to receive(:find).and_return(picture)
        end

        it "raises missing file error" do
          expect {
            alchemy_get :show, id: picture.id, name: picture.urlname, format: :png, sh: picture.security_token
          }.to raise_error(Alchemy::MissingImageFileError)
        end
      end

      context "Requesting a picture with crop_from and crop_size parameters" do
        let(:picture) do
          create(:picture, image_file: fixture_file_upload(File.expand_path('../../fixtures/500x500.png', __FILE__), 'image/png'))
        end

        it "renders the cropped picture" do
          alchemy_get :show, id: picture.id, name: picture.urlname, crop: 'crop', size: '123x44', crop_size: '123x44',
            crop_from: '0x0', format: :png,
            sh: picture.security_token(crop_size: '123x44', crop_from: '0x0', crop: true, size: '123x44')
          expect(response.body[0x10..0x18].unpack('NN')).to eq([123, 44])
        end
      end

      context "Requesting a picture with crop_from and crop_size parameters with different size param" do
        let(:picture) do
          create(:picture, image_file: fixture_file_upload(File.expand_path('../../fixtures/500x500.png', __FILE__), 'image/png'))
        end

        it "renders the cropped picture" do
          alchemy_get :show,
            id: picture.id,
            name: picture.urlname,
            crop: 'crop',
            size: '100x100',
            crop_size: '200x200',
            crop_from: '0x0',
            format: :png,
            sh: picture.security_token(
              crop_size: '200x200',
              crop_from: '0x0',
              crop: true,
              size: '100x100'
            )
         expect(response.body[0x10..0x18].unpack('NN')).to eq [100, 100]
        end
      end

      context "Requesting a picture with crop_from and crop_size parameters with larger size param" do
        let(:picture) do
          create(:picture, image_file: fixture_file_upload(File.expand_path('../../fixtures/500x500.png', __FILE__), 'image/png'))
        end

        it "renders the cropped picture without upsampling" do
          alchemy_get :show,
            id: picture.id,
            name: picture.urlname,
            crop: 'crop',
            size: '400x400',
            crop_size: '200x200',
            crop_from: '0x0',
            format: :png,
            sh: picture.security_token(
              crop_size: '200x200',
              crop_from: '0x0',
              crop: true,
              size: '400x400'
            )
          expect(response.body[0x10..0x18].unpack('NN')).to eq [200, 200]
        end
      end

      context "Requesting a picture with crop_from and crop_size parameters with larger size param and upsample set" do
        let(:picture) do
          create(:picture, image_file: fixture_file_upload(File.expand_path('../../fixtures/500x500.png', __FILE__), 'image/png'))
        end

        it "renders the cropped picture with upsampling" do
          alchemy_get :show,
            id: picture.id,
            name: picture.urlname,
            crop: 'crop',
            size: '400x400',
            crop_size: '200x200',
            crop_from: '0x0',
            format: :png,
            upsample: 'true',
            sh: picture.security_token(
              crop_size: '200x200',
              crop_from: '0x0',
              crop: true,
              size: '400x400',
              upsample: 'true'
            )
          expect(response.body[0x10..0x18].unpack('NN')).to eq [400, 400]
        end
      end

      context "Requesting a picture that is not assigned with any page" do
        it "should render the picture" do
          alchemy_get :show, id: picture.id, name: picture.urlname, format: :png, sh: picture.security_token
          expect(response.status).to eq(200)
        end
      end

      context "Requesting a picture that is assigned on restricted and non-restricted pages" do
        before do
          essence = element.contents.where(name: 'image').first.essence
          essence.picture_id = picture.id
          essence.save

          essence = restricted_element.contents.where(name: 'image').first.essence
          essence.picture_id = picture.id
          essence.save
        end

        context "as guest user" do
          it "should render the picture" do
            alchemy_get :show, id: picture.id, name: picture.urlname, format: :png, sh: picture.security_token
            expect(response.status).to eq(200)
          end
        end
      end

      context "Requesting a picture that is assigned with restricted pages only" do
        before do
          essence = restricted_element.contents.where(name: 'image').first.essence
          essence.picture_id = picture.id
          essence.save
        end

        context "as guest user" do
          it "should not render the picture, but redirect to login path" do
            alchemy_get :show, id: picture.id, name: picture.urlname, format: :png, sh: picture.security_token
            expect(response.status).to eq(302)
            expect(response).to redirect_to(Alchemy.login_path)
          end
        end

        context "as member user" do
          before do
            authorize_user(build(:alchemy_dummy_user))
          end

          it "should render the picture" do
            alchemy_get :show, id: picture.id, name: picture.urlname, format: :png, sh: picture.security_token
            expect(response.status).to eq(200)
          end
        end
      end
    end

    describe '#thumbnail' do
      let(:picture) do
        create(:picture, image_file: fixture_file_upload(File.expand_path('../../fixtures/500x500.png', __FILE__), 'image/png'))
      end

      context 'with size param set to small' do
        it "resizes the image to 80x60 while maintaining aspect ratio" do
          alchemy_get :thumbnail, id: picture.id, name: picture.urlname, size: 'small', format: :png, sh: picture.security_token(size: 'small')
          expect(response.body[0x10..0x18].unpack('NN')).to eq([60, 60])
        end
      end

      context 'with size param set to medium' do
        it "resizes the image to 160x120 while maintaining aspect ratio" do
          alchemy_get :thumbnail, id: picture.id, name: picture.urlname, size: 'medium', format: :png, sh: picture.security_token(size: 'medium')
          expect(response.body[0x10..0x18].unpack('NN')).to eq([120, 120])
        end
      end

      context 'with size param set to large' do
        it "resizes the image to 240x180 while maintaining aspect ratio" do
          alchemy_get :thumbnail, id: picture.id, name: picture.urlname, size: 'large', format: :png, sh: picture.security_token(size: 'large')
          expect(response.body[0x10..0x18].unpack('NN')).to eq([180, 180])
        end
      end

      context 'with size param set to nil' do
        it "resizes the image to 111x93 while maintaining aspect ratio" do
          alchemy_get :thumbnail, id: picture.id, name: picture.urlname, format: :png, sh: picture.security_token
          expect(response.body[0x10..0x18].unpack('NN')).to eq([93, 93])
        end
      end

      context 'with size param set to another value' do
        it "resizes the image to the given size while maintaining aspect ratio" do
          alchemy_get :thumbnail, id: picture.id, name: picture.urlname, size: '33x33', format: :png, sh: picture.security_token(size: '33x33')
          expect(response.body[0x10..0x18].unpack('NN')).to eq([33, 33])
        end
      end

      context "Requesting a picture that is assigned with restricted pages only" do
        before do
          essence = restricted_element.contents.where(name: 'image').first.essence
          essence.picture_id = picture.id
          essence.save
        end

        context "as guest user" do
          it "should not render the picture, but redirect to login path" do
            alchemy_get :thumbnail, id: picture.id, name: picture.urlname, format: :png, sh: picture.security_token
            expect(response.status).to eq(302)
            expect(response).to redirect_to(Alchemy.login_path)
          end
        end

        context "as member user" do
          before do
            authorize_user(build(:alchemy_dummy_user))
          end

          it "should render the picture" do
            alchemy_get :thumbnail, id: picture.id, name: picture.urlname, format: :png, sh: picture.security_token
            expect(response.status).to eq(200)
          end
        end
      end
    end

    describe 'Picture processing' do
      let(:big_picture) do
        create(:picture, image_file: fixture_file_upload(File.expand_path('../../fixtures/80x60.png', __FILE__), 'image/png'))
      end

      context "with crop and size parameters" do
        it "should return a cropped image." do
          options = {
            crop: 'crop',
            size: '10x10',
            format: 'png'
          }
          alchemy_get :show, options.merge(id: big_picture.id, name: big_picture.urlname, sh: big_picture.security_token(options))
          expect(response.body[0x10..0x18].unpack('NN')).to eq([10,10])
        end

        context "without a full size specification" do
          it "should raise an error" do
            options = {
              crop: 'crop',
              size: '10',
              format: 'png'
            }
            expect {
              alchemy_get :show, options.merge(id: big_picture.id, name: big_picture.urlname, sh: big_picture.security_token(options))
            }.to raise_error ArgumentError
          end
        end

        context "without upsample parameter" do
          it "should not upsample the image." do
            options = {
              crop: 'crop',
              size: '10x10',
              format: 'png'
            }
            alchemy_get :show, options.merge(id: picture.id, name: big_picture.urlname, sh: picture.security_token(options))
            expect(response.body[0x10..0x18].unpack('NN')).to eq([1,1])
          end
        end

        context "and with upsample true" do
          it "should return an upsampled image." do
            options = {
              crop: 'crop',
              size: '10x10',
              upsample: 'true',
              format: 'png'
            }
            alchemy_get :show, options.merge(id: picture.id, name: big_picture.urlname, sh: picture.security_token(options))
            expect(response.body[0x10..0x18].unpack('NN')).to eq([10,10])
          end
        end
      end

      context "without crop but with size parameter" do
        it "should resize the image preserving aspect ratio" do
          options = {
            size: '40x40',
            format: 'png'
          }
          alchemy_get :show, options.merge(id: big_picture.id, name: big_picture.urlname, sh: big_picture.security_token(options))
          expect(response.body[0x10..0x18].unpack('NN')).to eq([40,30])
        end

        it "should resize the image inferring the height if not given" do
          options = {
            size: '40x',
            format: 'png'
          }
          alchemy_get :show, options.merge(id: big_picture.id, name: big_picture.urlname, sh: big_picture.security_token(options))
          expect(response.body[0x10..0x18].unpack('NN')).to eq([40,30])
        end

        it "should resize the image inferring the width if not given" do
          options = {
            size: 'x30',
            format: 'png'
          }
          alchemy_get :show, options.merge(id: big_picture.id, name: big_picture.urlname, sh: big_picture.security_token(options))
          expect(response.body[0x10..0x18].unpack('NN')).to eq([40,30])
        end
      end
    end
  end
end
