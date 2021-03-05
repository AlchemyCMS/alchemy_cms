# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe PagesHelper do
    let(:language_root) { create(:alchemy_page, :language_root) }
    let(:public_page) { create(:alchemy_page, :public) }
    let(:klingon) { create(:alchemy_language, :klingon) }
    let(:klingon_language_root) { create(:alchemy_page, :language_root, language: klingon) }

    before do
      helper.controller.class_eval { include Alchemy::ConfigurationMethods }
      @root_page = language_root # We need this instance variable in the helpers
    end

    describe "#render_page_layout" do
      it "should render the current page layout" do
        @page = public_page
        expect(helper.render_page_layout).to have_selector("div#content")
      end
    end

    describe "#render_site_layout" do
      let(:default_site) { Alchemy::Site.default }

      it "renders the partial for current site" do
        expect(helper).to receive(:current_alchemy_site).and_return(default_site)
        expect(helper).to receive(:render).with(default_site)
        helper.render_site_layout
      end

      context "when block is given" do
        it "passes it on to the render method" do
          expect(helper).to receive(:current_alchemy_site).and_return(default_site)
          expect(helper)
            .to receive(:render)
            .with(default_site) { |&block| expect(block).to be }

          helper.render_site_layout { true }
        end
      end

      context "with missing partial" do
        it "returns empty string and logges warning" do
          expect(helper).to receive(:current_alchemy_site).twice.and_return(default_site)
          expect(helper.render_site_layout).to eq("")
        end
      end
    end

    describe "#render_menu" do
      subject { helper.render_menu(menu_type) }

      let(:menu_type) { "main_menu" }

      context "if menu exists" do
        let(:menu) { create(:alchemy_node, menu_type: menu_type) }
        let!(:node) { create(:alchemy_node, parent: menu, url: "/") }

        context "and the template exists" do
          it "renders the menu" do
            is_expected.to have_selector("ul.nav > li.nav-item > a.nav-link")
          end
        end

        context "but the template does not exist" do
          let(:menu_type) { "unknown" }

          it { is_expected.to be_nil }
        end
      end

      context "if menu does not exist" do
        it { is_expected.to be_nil }
      end

      context "with multiple sites" do
        let!(:site_2) { create(:alchemy_site, host: "another-site.com") }
        let!(:menu) { create(:alchemy_node, menu_type: menu_type, language: Alchemy::Language.current) }
        let!(:node) { create(:alchemy_node, parent: menu, url: "/default-site") }
        let!(:menu_2) { create(:alchemy_node, menu_type: menu_type, language: klingon) }
        let!(:node_2) { create(:alchemy_node, parent: menu_2, language: klingon, url: "/site-2") }

        it "renders menu from current site" do
          is_expected.to have_selector('ul.nav > li.nav-item > a.nav-link[href="/default-site"]')
        end
      end

      context "with multiple languages" do
        let!(:menu) { create(:alchemy_node, menu_type: menu_type) }
        let!(:node) { create(:alchemy_node, parent: menu, url: "/default") }
        let!(:klingon_menu) { create(:alchemy_node, menu_type: menu_type, language: klingon) }
        let!(:klingon_node) { create(:alchemy_node, parent: klingon_menu, language: klingon, url: "/klingon") }

        it "should return the menu for the current language" do
          is_expected.to have_selector('ul.nav > li.nav-item > a.nav-link[href="/default"]')
          is_expected.not_to have_selector('ul.nav > li.nav-item > a.nav-link[href="/klingon"]')
        end
      end
    end

    describe "#render_breadcrumb" do
      let(:parent) { create(:alchemy_page, :public) }
      let(:page) { create(:alchemy_page, :public, parent_id: parent.id) }
      let(:user) { nil }

      before do
        allow(helper).to receive(:multi_language?).and_return(false)
        allow(helper).to receive(:current_ability).and_return(Alchemy::Permissions.new(user))
      end

      subject do
        helper.render_breadcrumb(page: page)
      end

      it "should render a breadcrumb to current page" do
        is_expected.to have_selector(".active.last[contains('#{page.name}')]")
      end

      context "with options[:separator] given" do
        subject do
          helper.render_breadcrumb(page: page, separator: "<span>###</span>")
        end

        it "should render a breadcrumb with an alternative separator" do
          is_expected.to have_selector('span[contains("###")]')
        end
      end

      context "with options[:reverse] set to true" do
        subject do
          helper.render_breadcrumb(page: page, reverse: true)
        end

        it "should render a breadcrumb in reversed order" do
          is_expected.to have_selector('.active.first[contains("A Public Page")]')
        end
      end

      context "with options[:restricted_only] set to true" do
        let(:user) { build(:alchemy_dummy_user) }

        subject do
          helper.render_breadcrumb(page: page, restricted_only: true).strip
        end

        it "should render a breadcrumb of restricted pages only" do
          page.update_columns(restricted: true, urlname: "a-restricted-public-page", name: "A restricted Public Page", title: "A restricted Public Page")
          is_expected.to have_selector("*[contains(\"#{page.name}\")]")
          is_expected.to_not have_selector("*[contains(\"#{parent.name}\")]")
        end
      end

      it "should not include unpublished pages" do
        page.update_columns(urlname: "a-unpublic-page", name: "A Unpublic Page", title: "A Unpublic Page")
        page.public_version.destroy
        is_expected.to_not match(/A Unpublic Page/)
      end

      context "with options[:without]" do
        subject do
          helper.render_breadcrumb(page: page, without: page)
        end

        it "should render a breadcrumb without this page" do
          page.update_columns(urlname: "not-me", name: "Not Me", title: "Not Me")
          is_expected.not_to match(/Not Me/)
        end
      end

      context "with options[:without] as array" do
        subject do
          helper.render_breadcrumb(page: page, without: [page])
        end

        it "should render a breadcrumb without these pages." do
          page.update_columns(urlname: "not-me", name: "Not Me", title: "Not Me")
          is_expected.not_to match(/Not Me/)
        end
      end
    end

    describe "#language_links" do
      context "with another site, root page and language present" do
        let!(:second_site) { create(:alchemy_site, name: "Other", host: "example.com") }
        let!(:language_root_2) { create(:alchemy_page, :language_root, name: "Intro", language: klingon_2) }
        let!(:public_page_2) { create(:alchemy_page, :public, language: klingon_2) }
        let!(:klingon_2) { create(:alchemy_language, :klingon, site: second_site) }

        before { klingon_language_root }

        it "should still only render two links" do
          expect(helper.language_links).to have_selector("a", count: 2)
        end
      end

      context "with two public languages on the same site" do
        # Always create second language
        before { klingon }

        context "with only one language root page" do
          it "should return nil" do
            expect(helper.language_links).to be_nil
          end
        end

        context "with two language root pages" do
          # Always create a language root page for klingon
          before { klingon_language_root }

          it "should render two language links" do
            expect(helper.language_links).to have_selector("a", count: 2)
          end

          it "should render language links referring to their language root page" do
            code = klingon_language_root.language_code
            urlname = klingon_language_root.urlname
            expect(helper.language_links).to have_selector("a.#{code}[href='/#{code}/#{urlname}']")
          end

          context "with options[:linkname]" do
            context "set to 'name'" do
              it "should render the name of the language" do
                expect(helper.language_links(linkname: "name")).to have_selector("span[contains('#{klingon_language_root.language.name}')]")
              end
            end

            context "set to 'code'" do
              it "should render the code of the language" do
                expect(helper.language_links(linkname: "code")).to have_selector("span[contains('#{klingon_language_root.language.code}')]")
              end
            end
          end

          context "spacer set to '\o/'" do
            it "should render the given string as a spacer" do
              expect(helper.language_links(spacer: '<span>\o/</span>')).to have_selector('span[contains("\o/")]', count: 1)
            end
          end

          context "with options[:reverse]" do
            context "set to false" do
              it "should render the language links in an ascending order" do
                expect(helper.language_links(reverse: false)).to have_selector("a.kl + a.en")
              end
            end

            context "set to true" do
              it "should render the language links in a descending order" do
                expect(helper.language_links(reverse: true)).to have_selector("a.en + a.kl")
              end
            end
          end

          context "with options[:show_title]" do
            context "set to true" do
              it "should render the language links with titles" do
                allow(Alchemy).to receive(:t).and_return("my title")
                expect(helper.language_links(show_title: true)).to have_selector('a[title="my title"]')
              end
            end

            context "set to false" do
              it "should render the language links without titles" do
                expect(helper.language_links(show_title: false)).to_not have_selector("a[title]")
              end
            end
          end
        end
      end
    end

    describe "meta data" do
      before { @page = public_page }

      describe "#meta_description" do
        subject { helper.meta_description }

        context "when current page has a meta description set" do
          before { public_page.meta_description = "description of my public page" }
          it { is_expected.to eq "description of my public page" }
        end

        context "when current page has no meta description set" do
          before do
            language_root.meta_description = "description from language root"
            allow(Language).to receive_messages(current_root_page: language_root)
          end

          context "when #meta_description is an empty string" do
            before { public_page.meta_description = "" }

            it "returns the meta description of its language root page" do
              is_expected.to eq "description from language root"
            end
          end

          context "when #meta_description is nil" do
            before { public_page.meta_description = nil }

            it "returns the meta description of its language root page" do
              is_expected.to eq "description from language root"
            end
          end
        end
      end

      describe "#meta_keywords" do
        subject { helper.meta_keywords }

        context "when current page has meta keywords set" do
          before { public_page.meta_keywords = "keywords, from public page" }
          it { is_expected.to eq "keywords, from public page" }
        end

        context "when current page has no meta keywords set" do
          before do
            language_root.meta_keywords = "keywords, from language root"
            allow(Language).to receive_messages(current_root_page: language_root)
          end

          context "when #meta_keywords is an empty string" do
            before { public_page.meta_keywords = "" }

            it "returns the keywords of its language root page" do
              is_expected.to eq "keywords, from language root"
            end
          end

          context "when #meta_keywords is nil" do
            before { public_page.meta_keywords = nil }

            it "returns the keywords of its language root page" do
              is_expected.to eq "keywords, from language root"
            end
          end
        end
      end

      describe "#meta_robots" do
        subject { helper.meta_robots }

        context "when robots may index" do
          it "contains 'index'" do
            is_expected.to match /index/
          end

          context "and robots may follow the links" do
            it "contains 'follow'" do
              is_expected.to match /index, follow/
            end
          end

          context "and robots are not allowed to follow links" do
            before { allow(public_page).to receive_messages(robot_follow?: false) }

            it "contains 'nofollow'" do
              is_expected.to match /index, nofollow/
            end
          end
        end

        context "when robots are not allowed to index" do
          before { allow(public_page).to receive_messages(robot_index?: false) }

          it "contains 'noindex'" do
            is_expected.to match /noindex/
          end

          context "and robots may follow the links" do
            it "contains 'follow'" do
              is_expected.to match /noindex, follow/
            end
          end
          context "and robots are not allowed to follow links" do
            before { allow(public_page).to receive_messages(robot_follow?: false) }

            it "contains 'nofollow'" do
              is_expected.to match /noindex, nofollow/
            end
          end
        end
      end
    end

    describe "#picture_essence_caption" do
      let(:essence) { mock_model("EssencePicture", caption: "my caption") }
      let(:content) { mock_model("Content", essence: essence) }

      it "should return the caption of the contents essence" do
        expect(helper.picture_essence_caption(content)).to eq "my caption"
      end
    end
  end
end
