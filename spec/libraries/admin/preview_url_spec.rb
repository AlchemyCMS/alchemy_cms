# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::PreviewUrl do
  let(:preview_url) do
    described_class.new(routes: Alchemy::Engine.routes)
  end

  describe "#url_for" do
    let(:page) { create(:alchemy_page) }

    subject { preview_url.url_for(page) }

    context "without preview configured" do
      it "returns the admin pages preview url" do
        is_expected.to eq "/admin/pages/#{page.id}"
      end
    end

    context "with preview configured" do
      context "without protocol" do
        before do
          stub_alchemy_config(:preview, {
            "host" => "www.example.com",
          })
        end

        it "raises error" do
          expect { subject }.to raise_error(Alchemy::Admin::PreviewUrl::MissingProtocolError)
        end
      end

      context "as http url" do
        before do
          stub_alchemy_config(:preview, {
            "host" => "http://www.example.com",
          })
        end

        it "returns the configured preview url" do
          is_expected.to eq "http://www.example.com/#{page.urlname}?alchemy_preview_mode=true"
        end
      end

      context "as https url" do
        before do
          stub_alchemy_config(:preview, {
            "host" => "https://www.example.com",
          })
        end

        it "returns the configured preview url with https" do
          is_expected.to eq "https://www.example.com/#{page.urlname}?alchemy_preview_mode=true"
        end
      end

      context "and with basic auth configured" do
        before do
          stub_alchemy_config(:preview, {
            "host" => "https://www.example.com",
            "auth" => {
              "username" => "foo",
              "password" => "baz",
            },
          })
        end

        it "returns the configured preview url with userinfo" do
          is_expected.to eq "https://foo:baz@www.example.com/#{page.urlname}?alchemy_preview_mode=true"
        end
      end

      context "with a port configured" do
        before do
          stub_alchemy_config(:preview, {
            "host" => "https://www.example.com:8080",
          })
        end

        it "returns the configured preview url with userinfo" do
          is_expected.to eq "https://www.example.com:8080/#{page.urlname}?alchemy_preview_mode=true"
        end
      end

      context "for a site" do
        before do
          stub_alchemy_config(:preview, config)
        end

        context "that matches the pages site name" do
          let(:config) do
            {
              page.site.name => {
                "host" => "http://new.example.com",
              },
            }
          end

          it "returns the configured preview url for that site" do
            is_expected.to eq "http://new.example.com/#{page.urlname}?alchemy_preview_mode=true"
          end
        end

        context "that does not match the pages site name" do
          context "with a default configured" do
            let(:config) do
              {
                "Not matching site name" => {
                  "host" => "http://new.example.com",
                },
                "host" => "http://www.example.com",
              }
            end

            it "returns the default configured preview url" do
              is_expected.to eq "http://www.example.com/#{page.urlname}?alchemy_preview_mode=true"
            end
          end

          context "without a default configured" do
            let(:config) do
              {
                "Not matching site name" => {
                  "host" => "http://new.example.com",
                },
              }
            end

            it "returns the internal preview url" do
              is_expected.to eq "/admin/pages/#{page.id}"
            end
          end
        end
      end

      context "with page being the language root page" do
        let(:page) { create(:alchemy_page, :language_root) }

        before do
          stub_alchemy_config(:preview, {
            "host" => "https://www.example.com",
          })
        end

        it "returns the preview url without urlname" do
          is_expected.to eq "https://www.example.com/?alchemy_preview_mode=true"
        end
      end
    end
  end
end
