# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe UrlHelper do
    include Alchemy::ElementsHelper

    let(:page) { mock_model(Page, urlname: "testpage", language_code: "en") }

    context "page path helpers" do
      describe "#show_alchemy_page_path" do
        context "when prefix_locale? set to true" do
          before do
            allow(page).to receive(:url_path).with({}).and_return("/#{page.language_code}/testpage")
            allow(page).to receive(:url_path).with({query: "test"}).and_return("/#{page.language_code}/testpage?query=test")
          end

          it "should return the correct relative path string" do
            expect(helper.show_alchemy_page_path(page)).to eq("/#{page.language_code}/testpage")
          end

          it "should return the correct relative path string with additional parameters" do
            expect(helper.show_alchemy_page_path(page, {query: "test"})).to \
              eq("/#{page.language_code}/testpage?query=test")
          end
        end

        context "when prefix_locale? set to false" do
          before do
            allow(page).to receive(:url_path).with({}).and_return("/testpage")
            allow(page).to receive(:url_path).with({query: "test"}).and_return("/testpage?query=test")
          end

          it "should return the correct relative path string" do
            expect(helper.show_alchemy_page_path(page)).to eq("/testpage")
          end

          it "should return the correct relative path string with additional parameter" do
            expect(helper.show_alchemy_page_path(page, {query: "test"})).to \
              eq("/testpage?query=test")
          end
        end
      end

      describe "#show_alchemy_page_url" do
        context "when prefix_locale? set to true" do
          before do
            allow(page).to receive(:url_path).with({}).and_return("/#{page.language_code}/testpage")
            allow(page).to receive(:url_path).with({query: "test"}).and_return("/#{page.language_code}/testpage?query=test")
          end

          it "should return the correct url string" do
            expect(helper.show_alchemy_page_url(page)).to \
              eq("http://#{helper.request.host}/#{page.language_code}/testpage")
          end

          it "should return the correct url string with additional parameters" do
            expect(helper.show_alchemy_page_url(page, {query: "test"})).to \
              eq("http://#{helper.request.host}/#{page.language_code}/testpage?query=test")
          end
        end

        context "when prefix_locale? set to false" do
          before do
            allow(page).to receive(:url_path).with({}).and_return("/testpage")
            allow(page).to receive(:url_path).with({query: "test"}).and_return("/testpage?query=test")
          end

          it "should return the correct url string" do
            expect(helper.show_alchemy_page_url(page)).to \
              eq("http://#{helper.request.host}/testpage")
          end

          it "should return the correct url string with additional parameter" do
            expect(helper.show_alchemy_page_url(page, {query: "test"})).to \
              eq("http://#{helper.request.host}/testpage?query=test")
          end
        end
      end
    end

    context "attachment path helpers" do
      let(:attachment) { mock_model(Attachment, slug: "test-attachment.pdf") }

      it "should return the correct relative path to download an attachment" do
        expect(helper.download_alchemy_attachment_path(attachment)).to \
          eq("/attachment/#{attachment.id}/download/#{attachment.slug}")
      end

      it "should return the correct url to download an attachment" do
        expect(helper.download_alchemy_attachment_url(attachment)).to \
          eq("http://#{helper.request.host}/attachment/#{attachment.id}/download/#{attachment.slug}")
      end
    end
  end
end
