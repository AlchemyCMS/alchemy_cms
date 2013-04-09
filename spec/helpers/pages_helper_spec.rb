# encoding: utf-8
require 'spec_helper'

include Alchemy::BaseHelper

module Alchemy
  describe PagesHelper do

    # Fixtures
    let(:language)                  { mock_model('Language', :code => 'en') }
    let(:default_language)          { Language.get_default }
    let(:language_root)             { FactoryGirl.create(:language_root_page) }
    let(:public_page)               { FactoryGirl.create(:public_page) }
    let(:visible_page)              { FactoryGirl.create(:public_page, :visible => true) }
    let(:restricted_page)           { FactoryGirl.create(:public_page, :visible => true, :restricted => true) }
    let(:level_2_page)              { FactoryGirl.create(:public_page, :parent_id => visible_page.id, :visible => true, :name => 'Level 2') }
    let(:level_3_page)              { FactoryGirl.create(:public_page, :parent_id => level_2_page.id, :visible => true, :name => 'Level 3') }
    let(:level_4_page)              { FactoryGirl.create(:public_page, :parent_id => level_3_page.id, :visible => true, :name => 'Level 4') }
    let(:klingonian)                { FactoryGirl.create(:klingonian) }
    let(:klingonian_language_root)  { FactoryGirl.create(:language_root_page, :language => klingonian) }
    let(:klingonian_public_page)    { FactoryGirl.create(:public_page, :language => klingonian, :parent_id => klingonian_language_root.id) }

    before do
      Config.stub!(:get) { |arg| arg == :url_nesting ? true : Config.parameter(arg) }
      @root_page = language_root # We need this instance variable in the helpers
    end

    it "should render the current page layout" do
      @page = public_page
      helper.render_page_layout.should have_selector('div#content')
    end

    describe "#render_navigation" do
      before { visible_page }

      context "not in multi_language mode" do
        before { helper.stub(:multi_language?).and_return(false) }

        it "should render the page navigation" do
          helper.render_navigation.should have_selector("ul.navigation.level_1 li.#{visible_page.urlname} a[href=\"/#{visible_page.urlname}\"]")
        end

        context "as guest user" do
          before { restricted_page }

          it "should not render restricted pages" do
            helper.render_navigation.should_not have_selector("ul.navigation.level_1 li a[href=\"/#{restricted_page.urlname}\"]")
          end
        end

        context "as registered user" do
          before do
            restricted_page
            Authorization.stub!(:current_user).and_return(FactoryGirl.build(:registered_user))
          end

          it "should render restricted pages" do
            helper.render_navigation.should have_selector("ul.navigation.level_1 li a[href=\"/#{restricted_page.urlname}\"]")
          end
        end

        context "with enabled url nesting" do

          before do
            helper.stub!(:configuration).and_return(true)
            level_3_page
          end

          it "should render nested page links" do
            helper.render_navigation(:all_sub_menues => true).should have_selector("ul li a[href=\"/#{level_3_page.urlname}\"]")
          end

        end

      end

      context "with id and class in the html options" do

        it "should append id to the generated ul tag" do
          helper.render_navigation({}, {:id => 'foobar_id'}).should have_selector("ul[id='foobar_id']")
        end

        it "should replace the default css class from the generated ul tag" do
          helper.render_navigation({}, {:class => 'foobar_class'}).should have_selector("ul[class='foobar_class']")
        end

      end

      context "with options[:deepness] set" do
        before { level_3_page }

        it "shows only pages up to this depth" do
          output = helper.render_navigation(deepness: 3, all_sub_menues: true)
          output.should have_selector("ul li a[href=\"/#{level_2_page.urlname}\"]")
          output.should_not have_selector("ul li a[href=\"/#{level_3_page.urlname}\"]")
        end
      end

      context "with options[:spacer] set" do
        before { visible_page }

        context "with two pages on same level" do
          before { FactoryGirl.create(:public_page, visible: true) }

          it "should render the given spacer" do
            helper.render_navigation(spacer: '•').should match(/•/)
          end
        end

        context "only one page in current level" do
          it "should not render the spacer" do
            helper.render_navigation(spacer: '•').should_not match(/•/)
          end
        end
      end

    end

    describe '#render_subnavigation' do

      before do
        helper.stub(:multi_language?).and_return(false)
      end

      it "should return nil if no @page is set" do
        helper.render_subnavigation.should be(nil)
      end

      context "showing a page with level 2" do

        before { @page = level_2_page }

        it "should render the navigation from current page" do
          helper.render_subnavigation.should have_selector("ul > li > a[href='/#{level_2_page.urlname}']")
        end

        it "should set current page active" do
          helper.render_subnavigation.should have_selector("a[href='/#{level_2_page.urlname}'].active")
        end

      end

      context "showing a page with level 3" do

        before { @page = level_3_page }

        it "should render the navigation from current pages parent" do
          helper.render_subnavigation.should have_selector("ul > li > ul > li > a[href='/#{level_3_page.urlname}']")
        end

        it "should set current page active" do
          helper.render_subnavigation.should have_selector("a[href='/#{level_3_page.urlname}'].active")
        end

      end

      context "showing a page with level 4" do

        before { @page = level_4_page }

        it "should render the navigation from current pages parents parent" do
          helper.render_subnavigation.should have_selector("ul > li > ul > li > ul > li > a[href='/#{level_4_page.urlname}']")
        end

        it "should set current page active" do
          helper.render_subnavigation.should have_selector("a[href='/#{level_4_page.urlname}'].active")
        end

        context "beginning with level 3" do

          it "should render the navigation beginning from its parent" do
            helper.render_subnavigation(:level => 3).should have_selector("ul > li > ul > li > a[href='/#{level_4_page.urlname}']")
          end

        end

      end

    end

    describe "#render_breadcrumb" do
      let(:parent)    { FactoryGirl.create(:public_page, visible: true) }
      let(:page)      { FactoryGirl.create(:public_page, parent_id: parent.id, visible: true) }

      before do
        helper.stub(:multi_language?).and_return(false)
      end

      it "should render a breadcrumb to current page" do
        helper.render_breadcrumb(page: page).should have_selector(".active.last[contains('#{page.name}')]")
      end

      context "with options[:seperator] given" do
        it "should render a breadcrumb with an alternative seperator" do
          helper.render_breadcrumb(page: page, seperator: '<span>###</span>').should have_selector('span[contains("###")]')
        end
      end

      context "with options[:reverse] set to true" do
        it "should render a breadcrumb in reversed order" do
          helper.render_breadcrumb(page: page, reverse: true).should have_selector('.active.first[contains("A Public Page")]')
        end
      end

      context "with options[:restricted_only] set to true" do
        it "should render a breadcrumb of restricted pages only" do
          page.update_attributes!(restricted: true, urlname: 'a-restricted-public-page', name: 'A restricted Public Page', title: 'A restricted Public Page')
          helper.render_breadcrumb(page: page, restricted_only: true).strip.should match(/^(<span(.[^>]+)>)A restricted Public Page/)
        end
      end

      context "with options[:visible_only] set to true" do
        it "should render a breadcrumb of visible pages only." do
          page.update_attributes!(visible: false, urlname: 'a-invisible-public-page', name: 'A invisible Public Page', title: 'A invisible Public Page')
          helper.render_breadcrumb(page: page, visible_only: true).should_not match(/A invisible Public Page/)
        end
      end

      context "with options[:visible_only] set to false" do
        it "should render a breadcrumb of visible and invisible pages." do
          page.update_attributes!(visible: false, urlname: 'a-invisible-public-page', name: 'A invisible Public Page', title: 'A invisible Public Page')
          helper.render_breadcrumb(page: page, visible_only: false).should match(/A invisible Public Page/)
        end
      end

      context "with options[:public_only] set to true" do
        it "should render a breadcrumb of published pages only" do
          page.update_attributes!(public: false, urlname: 'a-unpublic-page', name: 'A Unpublic Page', title: 'A Unpublic Page')
          helper.render_breadcrumb(page: page, public_only: true).should_not match(/A Unpublic Page/)
        end
      end

      context "with options[:public_only] set to false" do
        it "should render a breadcrumb of published and unpublished pages." do
          page.update_attributes!(public: false, urlname: 'a-unpublic-page', name: 'A Unpublic Page', title: 'A Unpublic Page')
          helper.render_breadcrumb(page: page, public_only: false).should match(/A Unpublic Page/)
        end
      end

      context "with options[:without]" do
        it "should render a breadcrumb without this page" do
          page.update_attributes!(urlname: 'not-me', name: 'Not Me', title: 'Not Me')
          helper.render_breadcrumb(page: page, without: page).should_not match(/Not Me/)
        end
      end

      context "with options[:without] as array" do
        it "should render a breadcrumb without these pages." do
          page.update_attributes!(urlname: 'not-me', name: 'Not Me', title: 'Not Me')
          helper.render_breadcrumb(page: page, without: [page]).should_not match(/Not Me/)
        end
      end
    end

    describe "#render_meta_data" do

      it "should render meta keywords of current page" do
        @page = mock_model('Page', :language => language, :title => 'A Public Page', :meta_description => '', :meta_keywords => 'keyword1, keyword2', :robot_index? => false, :robot_follow? => false, :contains_feed? => false, :updated_at => '2011-11-29-23:00:00')
        helper.render_meta_data.should have_selector('meta[name="keywords"][content="keyword1, keyword2"]')
      end

      it "should render meta description 'blah blah' of current page" do
        @page = mock_model('Page', :language => language, :title => 'A Public Page', :meta_description => 'blah blah', :meta_keywords => '', :robot_index? => false, :robot_follow? => false, :contains_feed? => false, :updated_at => '2011-11-29-23:00:00')
        helper.render_meta_data.should have_selector('meta[name="description"][content="blah blah"]')
      end
    end

    describe "#render_title_tag" do

      it "should render a title tag for current page" do
        @page = mock_model('Page', :title => 'A Public Page')
        helper.render_title_tag.should have_selector('title[contains("A Public Page")]')
      end

      it "should render a title tag for current page with a prefix and a seperator" do
        @page = mock_model('Page', :title => 'A Public Page')
        helper.render_title_tag(:prefix => 'Peters Petshop', :seperator => ' ### ').should have_selector('title[contains("Peters Petshop ### A Public Page")]')
      end

    end

    describe "#language_switcher" do

      before do
        # simulates link_to_public_child = true
        helper.stub(:multi_language?).and_return(true)
        helper.stub(:configuration) { |arg| arg == :redirect_to_public_child ? true : false }
      end

      it "should return nil when having only one public language" do
        helper.language_switcher.should be nil
      end

      context "with two public languages and two language_roots" do

        before do
          language_root
        end

        context "and config redirect_to_public_child is set to TRUE" do

          it "should return nil if only one language_root is public and both do not have children" do
            klingonian_language_root.update_attributes(:public => false)
            helper.language_switcher.should == nil
          end

          it "should return nil if only one language_root is public and both have none public children" do
            klingonian_language_root.update_attributes(:public => false)
            FactoryGirl.create(:page)
            FactoryGirl.create(:page, :language => klingonian, :parent_id => klingonian_language_root.id)
            helper.language_switcher.should == nil
          end

          it "should render two links when having two public language_root pages" do
            klingonian_language_root
            helper.language_switcher.should have_selector('a', :count => 2)
          end

          it "should render two links when having just one public language_root but a public children in both language_roots" do
            klingonian_language_root.update_attributes(:public => false)
            public_page
            klingonian_public_page
            helper.language_switcher.should have_selector('a', :count => 2)
          end

          it "should render two links when having two not public language_roots but a public children in both" do
            language_root.update_attributes(:public => false)
            klingonian_language_root.update_attributes(:public => false)
            public_page
            klingonian_public_page
            helper.language_switcher.should have_selector('a', :count => 2)
          end

          it "should return nil when having two not public language_roots and a public children in only one of them" do
            language_root.update_attributes(:public => false)
            klingonian_language_root.update_attributes(:public => false)
            FactoryGirl.create(:page)
            klingonian_public_page
            helper.language_switcher.should == nil
          end

        end

        context "and config redirect_to_public_child is set to FALSE" do

          before do
            klingonian_language_root
            # simulates link_to_public_child = false
            helper.stub(:configuration).and_return(false)
          end

          it "should render two links when having two public language_root pages" do
            helper.language_switcher.should have_selector('a', :count => 2)
          end

          it "should render nil when having just one public language_root but a public children in both language_roots" do
            klingonian_language_root.update_attributes(:public => false)
            public_page
            klingonian_public_page
            helper.language_switcher.should == nil
          end

          it "should render nil when having two not public language_roots but a public children in both" do
            language_root.update_attributes(:public => false)
            klingonian_language_root.update_attributes(:public => false)
            public_page
            klingonian_public_page
            helper.language_switcher.should == nil
          end

        end

      end

    end

  end
end
