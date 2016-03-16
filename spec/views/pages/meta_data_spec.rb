require 'spec_helper'
module Alchemy
  describe 'alchemy/pages/_meta_data' do
    let(:root_page)       { Page.new(public_version: PageVersion.new) }
    let(:page_version)    { PageVersion.new(title: "Road Runner") }

    let(:page) do
      Page.new(
        language_code: "en",
        urlname: "roadrunner",
        public_version: page_version)
    end

    let(:title_prefix)    { "" }
    let(:title_separator) { "" }

    subject do
      render "alchemy/pages/meta_data", title_prefix: title_prefix, title_separator: title_separator
    end

    context "when current page is set" do
      before { view.instance_variable_set('@page', page) }

      describe "meta keywords" do
        context "are set" do
          before { allow(page_version).to receive_messages(meta_keywords: 'cartoon, road runner') }

          it "renders the keywords in the correct meta tag" do
            is_expected.to match /meta name="keywords" content="cartoon, road runner" lang="en"/
          end
        end

        context "are not set" do
          before { allow(page).to receive(:get_language_root).and_return(root_page) }

          context "but the language root page has meta keywords" do
            before do
              root_page.public_version.meta_keywords = "keywords, language, root"
            end

            it "renders its keywords in the correct meta tag" do
              is_expected.to match /meta name="keywords" content="keywords, language, root" lang="en"/
            end
          end

          context "and the language root page is also missing meta keywords" do
            before do
              root_page.public_version.meta_keywords = ""
            end

            it "does not render the meta keywords tag" do
              is_expected.not_to match /meta name="keywords"/
            end
          end
        end
      end

      describe "meta description" do
        context "is set" do
          before do
            allow(page_version).to receive_messages(meta_description: 'road runner goes meep meep')
          end

          it "renders the description in the correct meta tag" do
            is_expected.to match /meta name="description" content="road runner goes meep meep"/
          end
        end

        context "is not set" do
          before do
            allow(page).to receive(:get_language_root).and_return(root_page)
          end

          context "but the language root page has a meta description" do
            before do
              root_page.public_version.meta_description = "description from language root"
            end

            it "renders its description in the correct meta tag" do
              is_expected.to match /meta name="description" content="description from language root"/
            end
          end

          context "and the language root page is also missing a meta description" do
            before do
              root_page.public_version.meta_description = ""
            end

            it "does not render the meta description tag" do
              is_expected.not_to match /meta name="description"/
            end
          end
        end
      end

      describe "rss feed" do
        context "is provided" do
          before do
            allow(page).to receive_messages(contains_feed?: true)
            allow(view).to receive_messages(prefix_locale?: false)
          end

          it "renders a link to the feed" do
            is_expected.to match /link rel="alternate" type="application\/rss\+xml" title="RSS" href="http:\/\/#{view.request.host}\/roadrunner.rss"/
          end
        end

        context "is not provided" do
          it "does not render a feed link" do
            is_expected.not_to match /link rel="alternate" type="application\/rss\+xml" title="RSS"/
          end
        end
      end

      describe "title" do
        it "renders the title tag for the current page" do
          is_expected.to match /<title>Road Runner<\/title>/
        end

        context "with a given prefix and separator" do
          let(:title_prefix)    { "C64" }
          let(:title_separator) { " - " }

          it "renders the prefixed title" do
            is_expected.to match /<title>C64 - Road Runner<\/title>/
          end
        end
      end

      describe "meta robots" do
        context "when robots may index" do
          it "renders 'index'" do
            is_expected.to match /meta name="robots" content="index/
          end

          context "and robots may follow the links" do
            it "renders 'follow'" do
              is_expected.to match /meta name="robots" content="index, follow"/
            end
          end

          context "and robots are not allowed to follow links" do
            before { allow(page).to receive_messages(robot_follow?: false) }

            it "renders 'nofollow'" do
              is_expected.to match /meta name="robots" content="index, nofollow"/
            end
          end
        end

        context "when robots are not allowed to index" do
          before { allow(page).to receive_messages(robot_index?: false) }

          it "renders 'noindex'" do
            is_expected.to match /meta name="robots" content="noindex/
          end

          context "and robots may follow the links" do
            it "renders 'follow'" do
              is_expected.to match /meta name="robots" content="noindex, follow"/
            end
          end
          context "and robots are not allowed to follow links" do
            before { allow(page).to receive_messages(robot_follow?: false) }

            it "renders 'nofollow'" do
              is_expected.to match /meta name="robots" content="noindex, nofollow"/
            end
          end
        end
      end
    end

    context "when current page is not set" do
      it "renders nothing" do
        is_expected.to eq ""
      end
    end
  end
end
