# encoding: utf-8
require 'spec_helper'

module Alchemy
  describe Picture do

    it_behaves_like "has image transformations" do
      let(:picture) { FactoryGirl.build_stubbed(:picture) }
    end

    let :image_file do
      File.new(File.expand_path('../../fixtures/image.png', __FILE__))
    end

    let(:picture) { Picture.new }

    it "is valid with valid attributes" do
      picture = Picture.new(image_file: image_file)
      expect(picture).to be_valid
    end

    it "is not valid without image file" do
      picture = Picture.new
      expect(picture).not_to be_valid
    end

    it "is valid with capitalized image file extension" do
      image_file = File.new(File.expand_path('../../fixtures/image2.PNG', __FILE__))
      picture = Picture.new(image_file: image_file)
      expect(picture).to be_valid
    end

    it "is valid with jpeg image file extension" do
      image_file = File.new(File.expand_path('../../fixtures/image3.jpeg', __FILE__))
      picture = Picture.new(image_file: image_file)
      expect(picture).to be_valid
    end

    context 'with enabled preprocess_image_resize config option' do
      let(:image_file) do
        File.new(File.expand_path('../../fixtures/80x60.png', __FILE__))
      end

      before do
        allow(Config).to receive(:get) do |arg|
          if arg == :preprocess_image_resize
            '10x10'
          end
        end
      end

      it "it resizes the image after upload" do
        picture = Picture.new(image_file: image_file)
        expect(picture.image_file.data[0x10..0x18].unpack('NN')).to eq([10, 8])
      end
    end

    describe '#suffix' do
      it "should return the suffix of original filename" do
        pic = stub_model(Picture, image_file_name: 'kitten.JPG')
        allow(pic).to receive(:image_file).and_return(OpenStruct.new({ext: 'jpg'}))
        expect(pic.suffix).to eq("jpg")
      end

      context "image has no suffix" do
        it "should return empty string" do
          pic = stub_model(Picture, image_file_name: 'kitten')
          allow(pic).to receive(:image_file).and_return(OpenStruct.new({ext: ''}))
          expect(pic.suffix).to eq("")
        end
      end
    end

    describe '#humanized_name' do
      it "should return a humanized version of original filename" do
        pic = stub_model(Picture, image_file_name: 'cute_kitten.JPG')
        allow(pic).to receive(:image_file).and_return(OpenStruct.new({ext: 'jpg'}))
        expect(pic.humanized_name).to eq("cute kitten")
      end

      it "should not remove incidents of suffix from filename" do
        pic = stub_model(Picture, image_file_name: 'cute_kitten_mo.jpgi.JPG')
        allow(pic).to receive(:image_file).and_return(OpenStruct.new({ext: 'jpg'}))
        expect(pic.humanized_name).to eq("cute kitten mo.jpgi")
        expect(pic.humanized_name).not_to eq("cute kitten moi")
      end

      context "image has no suffix" do
        it "should return humanized name" do
          pic = stub_model(Picture, image_file_name: 'cute_kitten')
          allow(pic).to receive(:suffix).and_return("")
          expect(pic.humanized_name).to eq("cute kitten")
        end
      end
    end

    describe '#security_token' do
      before { @pic = stub_model(Picture, id: 1) }

      it "should return a sha1 hash" do
        expect(@pic.security_token).to match(/\b([a-f0-9]{16})\b/)
      end

      it "should return a 16 chars long hash" do
        @pic.security_token.length == 16
      end

      it "should convert crop true value into string" do
        digest = PictureAttributes.secure({id: @pic.id, crop: 'crop'})
        expect(@pic.security_token(crop: true)).to eq(digest)
      end

      it "should always include picture id" do
        digest = PictureAttributes.secure({id: @pic.id})
        expect(@pic.security_token).to eq(digest)
      end

      it "should remove all not suitable options" do
        digest = PictureAttributes.secure({id: @pic.id})
        expect(@pic.security_token({foo: 'baz'})).to eq(digest)
      end

      it "should remove all option values that have nil values" do
        digest = PictureAttributes.secure({id: @pic.id})
        expect(@pic.security_token({crop: nil})).to eq(digest)
      end
    end

    describe '.filtered_by' do
      let(:picture) { FactoryGirl.build_stubbed(:picture) }

      context "with 'recent' as argument" do
        it 'should call the .recent scope' do
          expect(Picture).to receive(:recent).and_return(picture)
          expect(Picture.filtered_by('recent')).to eq(picture)
        end
      end

      context "with 'last_upload' as argument" do
        it 'should call the .last_upload scope' do
          expect(Picture).to receive(:last_upload).and_return(picture)
          expect(Picture.filtered_by('last_upload')).to eq(picture)
        end
      end

      context "with 'without_tag' as argument" do
        it 'should call the .without_tag scope' do
          expect(Picture).to receive(:without_tag).and_return(picture)
          expect(Picture.filtered_by('without_tag')).to eq(picture)
        end
      end

      context "with no argument" do
        it 'should return the scoped collection' do
          expect(Picture).to receive(:all).and_return(picture)
          expect(Picture.filtered_by('')).to eq(picture)
        end
      end
    end

    describe '.last_upload' do
      it "should return all pictures that have the same upload-hash as the most recent picture" do
        other_upload = Picture.create!(image_file: image_file, upload_hash: '456')
        same_upload = Picture.create!(image_file: image_file, upload_hash: '123')
        most_recent = Picture.create!(image_file: image_file, upload_hash: '123')

        expect(Picture.last_upload).to include(most_recent)
        expect(Picture.last_upload).to include(same_upload)
        expect(Picture.last_upload).not_to include(other_upload)

        [other_upload, same_upload, most_recent].each { |p| p.destroy }
      end
    end

    describe '.recent' do
      before do
        now = Time.now
        @recent = Picture.create!(image_file: image_file)
        @old_picture = Picture.create!(image_file: image_file)
        @recent.update_column(:created_at, now-23.hours)
        @old_picture.update_column(:created_at, now-10.days)
      end

      it "should return all pictures that have been created in the last 24 hours" do
        expect(Picture.recent).to include(@recent)
      end

      it "should not return old pictures" do
        expect(Picture.recent).not_to include(@old_picture)
      end
    end

    describe '#destroy' do
      context "a picture that is assigned in an essence" do
        let(:essence_picture) { EssencePicture.create }
        let(:picture) { FactoryGirl.create :picture }

        before do
          essence_picture.update_attributes(picture_id: picture.id)
        end

        it "should raise error message" do
          expect { picture.destroy }.to raise_error PictureInUseError
        end
      end
    end

    describe "#image_file_dimensions" do
      it "should return the width and height in the format of '1024x768'" do
        picture.image_file = image_file
        expect(picture.image_file_dimensions).to eq('1 x 1')
      end
    end

    describe '#update_name_and_tag_list!' do
      let(:picture) { Picture.new(image_file: image_file) }

      before { allow(picture).to receive(:save!).and_return(true) }

      it "updates tag_list" do
        expect(picture).to receive(:tag_list=).with('Foo')
        picture.update_name_and_tag_list!({pictures_tag_list: 'Foo'})
      end

      context 'name is present' do
        it "updates name" do
          expect(picture).to receive(:name=).with('Foo')
          picture.update_name_and_tag_list!({pictures_name: 'Foo'})
        end
      end

      context 'name is not present' do
        it "does not update name" do
          expect(picture).not_to receive(:name=).with('Foo')
          picture.update_name_and_tag_list!({pictures_name: ''})
        end
      end
    end

    describe '#urlname' do
      subject { picture.urlname }

      let(:picture) { build_stubbed(:picture, name: 'Cute kittens.jpg') }

      it "returns a uri escaped name" do
        is_expected.to eq('Cute+kittens')
      end

      context 'with blank name' do
        let(:picture) { build_stubbed(:picture, name: '') }

        it "returns generic name" do
          is_expected.to eq("image_#{picture.id}")
        end
      end
    end

    describe '#to_jq_upload' do
      subject { picture.to_jq_upload }

      let(:picture) { build_stubbed(:picture, image_file_name: 'cute-kittens.jpg', image_file_size: 1024) }

      it "returns a hash containing data for jquery fileuploader" do
        is_expected.to be_an_instance_of(Hash)
        is_expected.to include(name: picture.image_file_name)
        is_expected.to include(size: picture.image_file_size)
      end

      context 'with error' do
        let(:picture) { build_stubbed(:picture) }

        before do
          expect(picture).to receive(:errors).and_return({image_file: %w(stupid_cats)})
        end

        it "returns hash with error message" do
          is_expected.to be_an_instance_of(Hash)
          is_expected.to include(error: 'stupid_cats')
        end
      end
    end

    describe '#restricted?' do
      subject { picture.restricted? }

      let(:picture) { build_stubbed(:picture) }

      context 'is assigned on pages' do
        context 'that are all restricted' do
          before do
            expect(picture).to receive(:pages).at_least(:once).and_return double(
              not_restricted: double(blank?: true),
              any?: true
            )
          end

          it { is_expected.to be_truthy }
        end

        context 'that are not all restricted' do
          before do
            expect(picture).to receive(:pages).at_least(:once).and_return double(
              not_restricted: double(blank?: false),
              any?: true
            )
          end

          it { is_expected.to be_falsey }
        end
      end

      context 'is not assigned on any page' do
        before do
          expect(picture).to receive(:pages).and_return double(any?: false)
        end

        it { is_expected.to be_falsey }
      end
    end
  end
end
