# frozen_string_literal: true

require "rails_helper"

include Alchemy::ElementsHelper

module Alchemy
  describe UrlHelper do
    let(:page) { mock_model(Page, urlname: "testpage", language_code: "en") }

    before do
      helper.controller.class_eval { include Alchemy::ConfigurationMethods }
    end

    context "page path helpers" do
      describe "#show_page_path_params" do
        subject(:show_page_path_params) { helper.show_page_path_params(page) }

        context "if prefix_locale? is false" do
          before do
            expect(helper).to receive(:prefix_locale?) { false }
          end

          it "returns a Hash with urlname and no locale parameter" do
            expect(show_page_path_params).to include(urlname: "testpage")
            expect(show_page_path_params).to_not include(locale: "en")
          end

          context "with addiitonal parameters" do
            subject(:show_page_path_params) do
              helper.show_page_path_params(page, { query: "test" })
            end

            it "returns a Hash with urlname, no locale and query parameter" do
              expect(show_page_path_params).to \
                include(urlname: "testpage", query: "test")
              expect(show_page_path_params).to_not \
                include(locale: "en")
            end
          end
        end

        context "if prefix_locale? is false" do
          before do
            expect(helper).to receive(:prefix_locale?) { true }
          end

          it "returns a Hash with urlname and locale parameter" do
            expect(show_page_path_params).to \
              include(urlname: "testpage", locale: "en")
          end

          context "with additional parameters" do
            subject(:show_page_path_params) do
              helper.show_page_path_params(page, { query: "test" })
            end

            it "returns a Hash with urlname, locale and query parameter" do
              expect(show_page_path_params).to \
                include(urlname: "testpage", locale: "en", query: "test")
            end
          end
        end
      end

      describe "#show_alchemy_page_path" do
        context "when prefix_locale? set to true" do
          before do
            expect(helper).to receive(:prefix_locale?) { true }
          end

          it "should return the correct relative path string" do
            expect(helper.show_alchemy_page_path(page)).to eq("/#{page.language_code}/testpage")
          end

          it "should return the correct relative path string with additional parameters" do
            expect(helper.show_alchemy_page_path(page, { query: "test" })).to \
              eq("/#{page.language_code}/testpage?query=test")
          end
        end

        context "when prefix_locale? set to false" do
          before do
            expect(helper).to receive(:prefix_locale?) { false }
          end

          it "should return the correct relative path string" do
            expect(helper.show_alchemy_page_path(page)).to eq("/testpage")
          end

          it "should return the correct relative path string with additional parameter" do
            expect(helper.show_alchemy_page_path(page, { query: "test" })).to \
              eq("/testpage?query=test")
          end
        end
      end

      describe "#show_alchemy_page_url" do
        context "when prefix_locale? set to true" do
          before do
            expect(helper).to receive(:prefix_locale?) { true }
          end

          it "should return the correct url string" do
            expect(helper.show_alchemy_page_url(page)).to \
              eq("http://#{helper.request.host}/#{page.language_code}/testpage")
          end

          it "should return the correct url string with additional parameters" do
            expect(helper.show_alchemy_page_url(page, { query: "test" })).to \
              eq("http://#{helper.request.host}/#{page.language_code}/testpage?query=test")
          end
        end

        context "when prefix_locale? set to false" do
          before do
            expect(helper).to receive(:prefix_locale?) { false }
          end

          it "should return the correct url string" do
            expect(helper.show_alchemy_page_url(page)).to \
              eq("http://#{helper.request.host}/testpage")
          end

          it "should return the correct url string with additional parameter" do
            expect(helper.show_alchemy_page_url(page, { query: "test" })).to \
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

    describe "#full_url_for_element" do
      subject { full_url_for_element(element) }

      let(:element) { create(:alchemy_element, name: "headline") }
      let(:current_server) { "" }

      it "returns the url to this element" do
        is_expected.to eq("#{current_server}/#{element.page.urlname}##{element_dom_id(element)}")
      end
    end
  end
end
