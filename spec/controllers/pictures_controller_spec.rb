require 'spec_helper'

# Fixes missing method tempfile error
class Rack::Test::UploadedFile
  attr_reader :tempfile
end

module Alchemy
  describe PicturesController do

    let(:public_page)        { FactoryGirl.create(:public_page, restricted: false) }
    let(:restricted_page)    { FactoryGirl.create(:public_page, restricted: true) }
    let(:element)            { FactoryGirl.create(:element, page: public_page, name: 'bild', create_contents_after_create: true) }
    let(:restricted_element) { FactoryGirl.create(:element, page: restricted_page, name: 'bild', create_contents_after_create: true) }
    let(:picture)            { Picture.create(image_file: fixture_file_upload(File.expand_path('../../fixtures/image.png', __FILE__), 'image/png')) }

    describe '#zoom' do
      let(:picture) { Picture.create(image_file: fixture_file_upload(File.expand_path('../../fixtures/80x60.png', __FILE__), 'image/png')) }

      before { sign_in(editor_user) }

      it "renders the original image without any resizing" do
        get :zoom, id: picture.id, format: :png, sh: picture.security_token
        response.body[0x10..0x18].unpack('NN').should == [80, 60]
      end
    end

    context "Requesting a picture with tempared security token" do
      it "should render status 400" do
        get :show, id: picture.id, format: :png, sh: '14m4b4dh4ck3r'
        response.status.should == 400
      end
    end

    context "Requesting a picture with another format then the original image" do
      it "should convert the picture format" do
        get :show, id: picture.id, format: :jpeg, sh: picture.security_token
        response.content_type.should == 'image/jpeg'
      end
    end

    context "Requesting a picture with not allowed format" do
      it "should raise error" do
        expect {
          get :show, id: picture.id, format: :wim, sh: picture.security_token
        }.to raise_error(ActionController::UnknownFormat)
      end
    end

    describe '#thumbnail' do
      let(:picture) { Picture.create(image_file: fixture_file_upload(File.expand_path('../../fixtures/500x500.png', __FILE__), 'image/png')) }

      before { sign_in(author_user) }

      context 'with size param set to small' do
        it "resizes the image to 80x60 while maintaining aspect ratio" do
          get :thumbnail, id: picture.id, size: 'small', format: :png, sh: picture.security_token(size: 'small')
          response.body[0x10..0x18].unpack('NN').should == [60, 60]
        end
      end

      context 'with size param set to medium' do
        it "resizes the image to 160x120 while maintaining aspect ratio" do
          get :thumbnail, id: picture.id, size: 'medium', format: :png, sh: picture.security_token(size: 'medium')
          response.body[0x10..0x18].unpack('NN').should == [120, 120]
        end
      end

      context 'with size param set to large' do
        it "resizes the image to 240x180 while maintaining aspect ratio" do
          get :thumbnail, id: picture.id, size: 'large', format: :png, sh: picture.security_token(size: 'large')
          response.body[0x10..0x18].unpack('NN').should == [180, 180]
        end
      end

      context 'with size param set to nil' do
        it "resizes the image to 111x93 while maintaining aspect ratio" do
          get :thumbnail, id: picture.id, format: :png, sh: picture.security_token
          response.body[0x10..0x18].unpack('NN').should == [93, 93]
        end
      end

      context 'with size param set to another value' do
        it "resizes the image to the given size while maintaining aspect ratio" do
          get :thumbnail, id: picture.id, size: '33x33', format: :png, sh: picture.security_token(size: '33x33')
          response.body[0x10..0x18].unpack('NN').should == [33, 33]
        end
      end
    end

    context "Requesting a picture that has no image file attached" do
      before do
        picture.stub(image_file: nil)
        Picture.stub(find: picture)
      end

      it "raises missing file error" do
        expect {
          get :show, id: picture.id, format: :png, sh: picture.security_token
        }.to raise_error(Alchemy::MissingImageFileError)
      end
    end

    context "Requesting a picture with crop_from and crop_size parameters" do
      let(:picture) { Picture.create(image_file: fixture_file_upload(File.expand_path('../../fixtures/500x500.png', __FILE__), 'image/png')) }

      it "renders the cropped picture" do
        get :show, id: picture.id, crop: 'crop', size: '123x44', crop_size: '123x44', crop_from: '0x0', format: :png, sh: picture.security_token(crop_size: '123x44', crop_from: '0x0', crop: true, size: '123x44')
        response.body[0x10..0x18].unpack('NN').should == [123, 44]
      end
    end

    context "Requesting a picture that is not assigned with any page" do
      it "should render the picture" do
        get :show, id: picture.id, format: :png, sh: picture.security_token
        response.status.should == 200
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
          get :show, id: picture.id, format: :png, sh: picture.security_token
          response.status.should == 200
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
          get :show, id: picture.id, sh: picture.security_token
          response.status.should == 302
          response.should redirect_to(Alchemy.login_path)
        end
      end

      context "as member user" do
        before do
          sign_in(member_user)
        end

        it "should render the picture" do
          get :show, id: picture.id, format: :png, sh: picture.security_token
          response.status.should == 200
        end
      end
    end

    describe 'Picture processing' do
      let(:big_picture) { Picture.create(:image_file => fixture_file_upload(File.expand_path('../../fixtures/80x60.png', __FILE__), 'image/png')) }

      context "with crop and size parameters" do
        it "should return a cropped image." do
          options = {
            crop: 'crop',
            size: '10x10',
            format: 'png'
          }
          get :show, options.merge(id: big_picture.id, sh: big_picture.security_token(options))
          response.body[0x10..0x18].unpack('NN').should == [10,10]
        end

        context "without a full size specification" do
          it "should raise an error" do
            options = {
              :crop => 'crop',
              :size => '10',
              :format => 'png'
            }
            expect do
              get :show, options.merge(:id => big_picture.id, :sh => big_picture.security_token(options))
            end.to raise_error ArgumentError
          end
        end

        context "without upsample parameter" do
          it "should not upsample the image." do
            options = {
              crop: 'crop',
              size: '10x10',
              format: 'png'
            }
            get :show, options.merge(id: picture.id, sh: picture.security_token(options))
            response.body[0x10..0x18].unpack('NN').should == [1,1]
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
            get :show, options.merge(id: picture.id, sh: picture.security_token(options))
            response.body[0x10..0x18].unpack('NN').should == [10,10]
          end
        end
      end

      context "without crop but with size parameter" do
        it "should resize the image preserving aspect ratio" do
          options = {
            :size => '40x40',
            :format => 'png'
          }
          get :show, options.merge(:id => big_picture.id, :sh => big_picture.security_token(options))
          response.body[0x10..0x18].unpack('NN').should == [40,30]
        end

        it "should resize the image inferring the height if not given" do
          options = {
            :size => '40x',
            :format => 'png'
          }
          get :show, options.merge(:id => big_picture.id, :sh => big_picture.security_token(options))
          response.body[0x10..0x18].unpack('NN').should == [40,30]
        end

        it "should resize the image inferring the width if not given" do
          options = {
            :size => 'x30',
            :format => 'png'
          }
          get :show, options.merge(:id => big_picture.id, :sh => big_picture.security_token(options))
          response.body[0x10..0x18].unpack('NN').should == [40,30]
        end
      end
    end

  end
end
