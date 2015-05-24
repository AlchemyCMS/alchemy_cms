# encoding: utf-8
require 'spec_helper'

module Alchemy
  describe PagesHelper do

    # Fixtures
    let(:language)                 { mock_model('Language', :code => 'en') }
    let(:default_language)         { Language.default }
    let(:language_root)            { FactoryGirl.create(:language_root_page) }
    let(:public_page)              { FactoryGirl.create(:public_page) }
    let(:visible_page)             { FactoryGirl.create(:public_page, :visible => true) }
    let(:restricted_page)          { FactoryGirl.create(:public_page, :visible => true, :restricted => true) }
    let(:level_2_page)             { FactoryGirl.create(:public_page, :parent_id => visible_page.id, :visible => true, :name => 'Level 2') }
    let(:level_3_page)             { FactoryGirl.create(:public_page, :parent_id => level_2_page.id, :visible => true, :name => 'Level 3') }
    let(:level_4_page)             { FactoryGirl.create(:public_page, :parent_id => level_3_page.id, :visible => true, :name => 'Level 4') }
    let(:klingonian)               { FactoryGirl.create(:klingonian) }
    let(:klingonian_language_root) { FactoryGirl.create(:language_root_page, :language => klingonian) }
    let(:klingonian_public_page)   { FactoryGirl.create(:public_page, :language => klingonian, :parent_id => klingonian_language_root.id) }

    before do
      helper.controller.class_eval { include Alchemy::ConfigurationMethods }
      allow(Config).to receive(:get) { |arg| arg == :url_nesting ? true : Config.parameter(arg) }
      @root_page = language_root # We need this instance variable in the helpers
    end

    describe "#render_page_layout" do
      it "should render the current page layout" do
        @page = public_page
        expect(helper.render_page_layout).to have_selector('div#content')
      end
    end

    describe '#render_site_layout' do
      let(:default_site) { Alchemy::Site.default }

      it "renders the partial for current site" do
        expect(helper).to receive(:current_alchemy_site).and_return(default_site)
        expect(helper).to receive(:render).with(default_site)
        helper.render_site_layout
      end

      context "with missing partial" do
        it "returns empty string and logges warning" do
          expect(helper).to receive(:current_alchemy_site).twice.and_return(default_site)
          expect(helper.render_site_layout).to eq("")
        end
      end
    end

    describe "#render_navigation" do
      let(:user) { nil }

      before do
        visible_page
        allow(helper).to receive(:current_ability).and_return(Alchemy::Permissions.new(user))
      end

      it "should render only visible pages" do
        not_visible_page = FactoryGirl.create(:page, visible: false)
        expect(helper.render_navigation).not_to match(/#{not_visible_page.name}/)
      end

      it "should render visible unpublished pages" do
        unpublished_visible_page = FactoryGirl.create(:page, visible: true, public: false)
        expect(helper.render_navigation).to match(/#{unpublished_visible_page.name}/)
      end

      context "not in multi_language mode" do
        before { allow(helper).to receive(:multi_language?).and_return(false) }

        it "should render the page navigation" do
          expect(helper.render_navigation).to have_selector("ul.navigation.level_1 li.#{visible_page.urlname} a[href=\"/#{visible_page.urlname}\"]")
        end

        context "as guest user" do
          before { restricted_page }

          it "should not render restricted pages" do
            expect(helper.render_navigation).not_to have_selector("ul.navigation.level_1 li a[href=\"/#{restricted_page.urlname}\"]")
          end
        end

        context "as member user" do
          let(:user) { build(:alchemy_dummy_user) }

          before { restricted_page }

          it "should render also restricted pages" do
            not_restricted_page = FactoryGirl.create(:public_page, restricted: false, visible: true)
            expect(helper.render_navigation).to match(/#{restricted_page.name}/)
            expect(helper.render_navigation).to match(/#{not_restricted_page.name}/)
          end
        end

        context "with enabled url nesting" do
          before do
            allow(helper).to receive(:configuration).and_return(true)
            level_3_page
          end

          it "should render nested page links" do
            expect(helper.render_navigation(:all_sub_menues => true)).to have_selector("ul li a[href=\"/#{level_3_page.urlname}\"]")
          end
        end
      end

      context "with id and class in the html options" do
        it "should append id to the generated ul tag" do
          expect(helper.render_navigation({}, {:id => 'foobar_id'})).to have_selector("ul[id='foobar_id']")
        end

        it "should replace the default css class from the generated ul tag" do
          expect(helper.render_navigation({}, {:class => 'foobar_class'})).to have_selector("ul[class='foobar_class']")
        end
      end

      context "with options[:deepness] set" do
        before { level_3_page }

        it "shows only pages up to this depth" do
          output = helper.render_navigation(deepness: 3, all_sub_menues: true)
          expect(output).to have_selector("ul li a[href=\"/#{level_2_page.urlname}\"]")
          expect(output).not_to have_selector("ul li a[href=\"/#{level_3_page.urlname}\"]")
        end
      end

      context "with options[:spacer] set" do
        before { visible_page }

        context "with two pages on same level" do
          before { FactoryGirl.create(:public_page, visible: true) }

          it "should render the given spacer" do
            expect(helper.render_navigation(spacer: '•')).to match(/•/)
          end
        end

        context "only one page in current level" do
          it "should not render the spacer" do
            expect(helper.render_navigation(spacer: '•')).not_to match(/•/)
          end
        end
      end

      context "with options[:from_page] set" do
        before { level_2_page }

        context "passing a page object" do
          it "should render the pages underneath the given one" do
            output = helper.render_navigation(from_page: visible_page)
            expect(output).not_to have_selector("ul li a[href=\"/#{visible_page.urlname}\"]")
            expect(output).to have_selector("ul li a[href=\"/#{level_2_page.urlname}\"]")
          end
        end

        context "passing a page_layout" do
          it "should render the pages underneath the page with the given page_layout" do
            allow(helper).to receive(:page_or_find).with('contact').and_return(visible_page)
            output = helper.render_navigation(from_page: 'contact')
            expect(output).not_to have_selector("ul li a[href=\"/#{visible_page.urlname}\"]")
            expect(output).to have_selector("ul li a[href=\"/#{level_2_page.urlname}\"]")
          end
        end

        context "passing a page_layout of a not existing page" do
          it "should render nothing" do
            expect(helper.render_navigation(from_page: 'news')).to be_nil
          end
        end
      end
    end

    describe '#render_subnavigation' do
      let(:user) { nil }

      before {
        allow(helper).to receive(:multi_language?).and_return(false)
        allow(helper).to receive(:current_ability).and_return(Alchemy::Permissions.new(user))
      }

      it "should return nil if no @page is set" do
        expect(helper.render_subnavigation).to be(nil)
      end

      context "showing a page with level 2" do
        before { @page = level_2_page }

        it "should render the navigation from current page" do
          expect(helper.render_subnavigation).to have_selector("ul > li > a[href='/#{level_2_page.urlname}']")
        end

        it "should set current page active" do
          expect(helper.render_subnavigation).to have_selector("a[href='/#{level_2_page.urlname}'].active")
        end
      end

      context "showing a page with level 3" do
        before { @page = level_3_page }

        it "should render the navigation from current pages parent" do
          expect(helper.render_subnavigation).to have_selector("ul > li > ul > li > a[href='/#{level_3_page.urlname}']")
        end

        it "should set current page active" do
          expect(helper.render_subnavigation).to have_selector("a[href='/#{level_3_page.urlname}'].active")
        end
      end

      context "showing a page with level 4" do
        before { @page = level_4_page }

        it "should render the navigation from current pages parents parent" do
          expect(helper.render_subnavigation).to have_selector("ul > li > ul > li > ul > li > a[href='/#{level_4_page.urlname}']")
        end

        it "should set current page active" do
          expect(helper.render_subnavigation).to have_selector("a[href='/#{level_4_page.urlname}'].active")
        end

        context "beginning with level 3" do
          it "should render the navigation beginning from its parent" do
            expect(helper.render_subnavigation(:level => 3)).to have_selector("ul > li > ul > li > a[href='/#{level_4_page.urlname}']")
          end
        end
      end
    end

    describe "#render_breadcrumb" do
      let(:parent) { FactoryGirl.create(:public_page, visible: true) }
      let(:page)   { FactoryGirl.create(:public_page, parent_id: parent.id, visible: true) }
      let(:user)   { nil }

      before do
        allow(helper).to receive(:multi_language?).and_return(false)
        allow(helper).to receive(:current_ability).and_return(Alchemy::Permissions.new(user))
      end

      it "should render a breadcrumb to current page" do
        expect(helper.render_breadcrumb(page: page)).to have_selector(".active.last[contains('#{page.name}')]")
      end

      context "with options[:separator] given" do
        it "should render a breadcrumb with an alternative separator" do
          expect(helper.render_breadcrumb(page: page, separator: '<span>###</span>')).to have_selector('span[contains("###")]')
        end
      end

      context "with options[:reverse] set to true" do
        it "should render a breadcrumb in reversed order" do
          expect(helper.render_breadcrumb(page: page, reverse: true)).to have_selector('.active.first[contains("A Public Page")]')
        end
      end

      context "with options[:restricted_only] set to true" do
        let(:user) { build(:alchemy_dummy_user) }

        it "should render a breadcrumb of restricted pages only" do
          page.update_attributes!(restricted: true, urlname: 'a-restricted-public-page', name: 'A restricted Public Page', title: 'A restricted Public Page')
          result = helper.render_breadcrumb(page: page, restricted_only: true).strip
          expect(result).to have_selector("*[contains(\"#{page.name}\")]")
          expect(result).to_not have_selector("*[contains(\"#{parent.name}\")]")
        end
      end

      it "should render a breadcrumb of visible pages only" do
        page.update_attributes!(visible: false, urlname: 'a-invisible-page', name: 'A Invisible Page', title: 'A Invisible Page')
        expect(helper.render_breadcrumb(page: page)).not_to match(/A Invisible Page/)
      end

      it "should render a breadcrumb of visible and unpublished pages" do
        page.update_attributes!(public: false, urlname: 'a-unpublic-page', name: 'A Unpublic Page', title: 'A Unpublic Page')
        expect(helper.render_breadcrumb(page: page)).to match(/A Unpublic Page/)
      end

      context "with options[:without]" do
        it "should render a breadcrumb without this page" do
          page.update_attributes!(urlname: 'not-me', name: 'Not Me', title: 'Not Me')
          expect(helper.render_breadcrumb(page: page, without: page)).not_to match(/Not Me/)
        end
      end

      context "with options[:without] as array" do
        it "should render a breadcrumb without these pages." do
          page.update_attributes!(urlname: 'not-me', name: 'Not Me', title: 'Not Me')
          expect(helper.render_breadcrumb(page: page, without: [page])).not_to match(/Not Me/)
        end
      end
    end

    describe "#render_meta_data" do
      context "@page is not set" do
        it "should return nil" do
          expect(helper.render_meta_data).to eq(nil)
        end
      end

      context "@page is set" do
        let(:page) { mock_model('Page', language: language, title: 'A Public Page', meta_description: 'blah blah', meta_keywords: 'keyword1, keyword2', robot_index?: false, robot_follow?: false, contains_feed?: false, updated_at: '2011-11-29-23:00:00') }
        before { helper.instance_variable_set('@page', page) }
        subject { helper.render_meta_data }

        it "should render meta keywords of current page" do
          is_expected.to match /meta name="keywords" content="keyword1, keyword2"/
        end

        it "should render meta description 'blah blah' of current page" do
          is_expected.to match /meta name="description" content="blah blah"/
        end
      end
    end

    describe "#render_title_tag" do
      let(:page) { mock_model('Page', title: 'A Public Page') }
      before { helper.instance_variable_set('@page', page) }

      it "should render a title tag for current page" do
        expect(helper.render_title_tag).to match /<title>A Public Page<\/title>/
      end

      it "should render a title tag for current page with a prefix and a separator" do
        expect(helper.render_title_tag(prefix: 'Peters Petshop', separator: ' ### ')).to match /<title>Peters Petshop ### A Public Page<\/title>/
      end
    end

    describe "#language_links" do
      context "with two public languages" do
        # Always create second language
        before { klingonian }

        context "with only one language root page" do
          it "should return nil" do
            expect(helper.language_links).to be_nil
          end
        end

        context "with two language root pages" do
          # Always create a language root page for klingonian
          before { klingonian_language_root }

          it "should render two language links" do
            expect(helper.language_links).to have_selector('a', :count => 2)
          end

          it "should render language links referring to their language root page" do
            code = klingonian_language_root.language_code
            urlname = klingonian_language_root.urlname
            expect(helper.language_links).to have_selector("a.#{code}[href='/#{code}/#{urlname}']")
          end

          context "with options[:linkname]" do
            context "set to 'name'" do
              it "should render the name of the language" do
                expect(helper.language_links(linkname: 'name')).to have_selector("span[contains('#{klingonian_language_root.language.name}')]")
              end
            end

            context "set to 'code'" do
              it "should render the code of the language" do
                expect(helper.language_links(linkname: 'code')).to have_selector("span[contains('#{klingonian_language_root.language.code}')]")
              end
            end
          end

          context "spacer set to '\o/'" do
            it "should render the given string as a spacer" do
              expect(helper.language_links(spacer: '<span>\o/</span>')).to have_selector('span[contains("\o/")]', :count => 1)
            end
          end

          context "with options[:reverse]" do
            context "set to false" do
              it "should render the language links in an ascending order" do
                expect(helper.language_links(reverse: false)).to have_selector("a.en + a.kl")
              end
            end

            context "set to true" do
              it "should render the language links in a descending order" do
                expect(helper.language_links(reverse: true)).to have_selector("a.kl + a.en")
              end
            end
          end

          context "with options[:show_title]" do
            context "set to true" do
              it "should render the language links with titles" do
                allow(helper).to receive(:_t).and_return("my title")
                expect(helper.language_links(show_title: true)).to have_selector('a[title="my title"]')
              end
            end

            context "set to false" do
              it "should render the language links without titles" do
                expect(helper.language_links(show_title: false)).to_not have_selector('a[title]')
              end
            end
          end
        end
      end
    end

    describe "#picture_essence_caption" do
      let(:essence) { mock_model('EssencePicture', caption: 'my caption') }
      let(:content) { mock_model('Content', essence: essence) }

      it "should return the caption of the contents essence" do
        expect(helper.picture_essence_caption(content)).to eq "my caption"
      end
    end

  end
end
