require 'spec_helper'

include Alchemy::ElementsHelper

module Alchemy
  describe UrlHelper do
    let(:page) { mock_model(Page, urlname: 'testpage', language_code: 'en') }

    before do
      helper.controller.class_eval { include Alchemy::ConfigurationMethods }
    end

    context 'page path helpers' do
      describe "#show_page_path_params" do
        context "when multi_language" do

          before do
            allow(helper).to receive(:multi_language?).and_return(true)
          end

          it "should return a Hash with urlname and language_id parameter" do
            allow(helper).to receive(:multi_language?).and_return(true)
            expect(helper.show_page_path_params(page)).to include(urlname: 'testpage', locale: 'en')
          end

          it "should return a Hash with urlname, language_id and query parameter" do
            allow(helper).to receive(:multi_language?).and_return(true)
            expect(helper.show_page_path_params(page, {query: 'test'})).to include(urlname: 'testpage', locale: 'en', query: 'test')
          end
        end

        context "not multi_language" do
          before do
            allow(helper).to receive(:multi_language?).and_return(false)
          end

          it "should return a Hash with the urlname but without language_id parameter" do
            expect(helper.show_page_path_params(page)).to include(urlname: 'testpage')
            expect(helper.show_page_path_params(page)).not_to include(locale: 'en')
          end

          it "should return a Hash with urlname and query parameter" do
            expect(helper.show_page_path_params(page, {query: 'test'})).to include(urlname: 'testpage', query: 'test')
            expect(helper.show_page_path_params(page)).not_to include(locale: 'en')
          end
        end
      end

      describe "#show_alchemy_page_path" do
        context "when multi_language" do

          before do
            allow(helper).to receive(:multi_language?).and_return(true)
          end

          it "should return the correct relative path string" do
            expect(helper.show_alchemy_page_path(page)).to eq("/#{page.language_code}/testpage")
          end

          it "should return the correct relative path string with additional parameters" do
            expect(helper.show_alchemy_page_path(page, {query: 'test'})).to eq("/#{page.language_code}/testpage?query=test")
          end
        end

        context "not multi_language" do
          before do
            allow(helper).to receive(:multi_language?).and_return(false)
          end

          it "should return the correct relative path string" do
            expect(helper.show_alchemy_page_path(page)).to eq("/testpage")
          end

          it "should return the correct relative path string with additional parameter" do
            expect(helper.show_alchemy_page_path(page, {query: 'test'})).to eq("/testpage?query=test")
          end
        end
      end

      describe "#show_alchemy_page_url" do
        context "when multi_language" do

          before do
            allow(helper).to receive(:multi_language?).and_return(true)
          end

          it "should return the correct url string" do
            expect(helper.show_alchemy_page_url(page)).to eq("http://#{helper.request.host}/#{page.language_code}/testpage")
          end

          it "should return the correct url string with additional parameters" do
            expect(helper.show_alchemy_page_url(page, {query: 'test'})).to eq("http://#{helper.request.host}/#{page.language_code}/testpage?query=test")
          end
        end

        context "not multi_language" do
          before do
            allow(helper).to receive(:multi_language?).and_return(false)
          end

          it "should return the correct url string" do
            expect(helper.show_alchemy_page_url(page)).to eq("http://#{helper.request.host}/testpage")
          end

          it "should return the correct url string with additional parameter" do
            expect(helper.show_alchemy_page_url(page, {query: 'test'})).to eq("http://#{helper.request.host}/testpage?query=test")
          end
        end
      end
    end

    context 'picture path helpers' do
      let(:picture) { stub_model(Picture, urlname: 'cute_kitten', id: 42) }

      describe '#show_alchemy_picture_path' do
        it "should return the correct relative path string" do
          expect(helper.show_alchemy_picture_path(picture)).to match(Regexp.new("/pictures/42/show/cute_kitten.jpg"))
        end
      end

      describe '#show_alchemy_picture_url' do
        it "should return the correct url string" do
          expect(helper.show_alchemy_picture_url(picture)).to match(Regexp.new("http://#{helper.request.host}/pictures/42/show/cute_kitten.jpg"))
        end
      end

      describe '#show_picture_path_params' do
        it "should return the correct params for rendering a picture" do
          expect(helper.show_picture_path_params(picture)).to include(name: 'cute_kitten', format: 'jpg')
        end

        it "should include the secure hash parameter" do
          expect(helper.show_picture_path_params(picture).keys).to include(:sh)
          expect(helper.show_picture_path_params(picture)[:sh]).not_to be_empty
        end

        context "with additional params" do
          it "should include these params" do
            expect(helper.show_picture_path_params(picture, {format: 'png'})).to include(name: 'cute_kitten', format: 'png')
          end
        end

        context "with additional params crop set to true" do
          it "should include crop as parameter" do
            expect(helper.show_picture_path_params(picture, {crop: true})).to include(name: 'cute_kitten', crop: 'crop')
          end
        end
      end
    end

    context 'attachment path helpers' do
      let(:attachment) { mock_model(Attachment, urlname: 'test-attachment.pdf') }

      it 'should return the correct relative path to download an attachment' do
        expect(helper.download_alchemy_attachment_path(attachment)).to eq("/attachment/#{attachment.id}/download/#{attachment.urlname}")
      end

      it 'should return the correct url to download an attachment' do
        expect(helper.download_alchemy_attachment_url(attachment)).to eq("http://#{helper.request.host}/attachment/#{attachment.id}/download/#{attachment.urlname}")
      end
    end

    describe '#full_url_for_element' do
      subject { full_url_for_element(element) }

      let(:element) { build_stubbed(:alchemy_element, name: 'headline', page: page) }
      let(:current_server) { '' }

      it "returns the url to this element" do
        is_expected.to eq("#{current_server}/#{element.page.urlname}##{element_dom_id(element)}")
      end
    end
  end
end
