require 'spec_helper'

describe Alchemy::Admin::EssencesHelper do
  include Alchemy::Admin::ElementsHelper

  let(:element) { FactoryGirl.create(:element, :name => 'article', :create_contents_after_create => true) }

  describe 'essence rendering' do
    before do
      if element
        element.content_by_name('intro').essence.update(body: 'hello!')
      end
    end

    describe '#render_essence_editor' do
      it "should render an essence editor" do
        content = element.content_by_name('intro')
        helper.render_essence_editor(content).should match(/input.+type="text".+value="hello!/)
      end
    end

    describe '#render_essence_editor_by_name' do
      subject { render_essence_editor_by_name(element, content) }

      let(:content) { 'intro' }

      it "renders an essence editor by given name" do
        should match(/input.+type="text".+value="hello!/)
      end

      context 'when element is nil' do
        let(:element) { nil }

        it "displays a warning" do
          should have_selector(".content_editor_error")
          should have_content("No element given.")
        end
      end

      context 'when content is not found on element' do
        let(:content) { 'sputz' }

        it "displays a warning" do
          should have_selector(".content_editor.missing")
        end
      end
    end
  end

  describe '#pages_for_select' do
    let(:contact_form) { FactoryGirl.create(:element, :name => 'contactform', :create_contents_after_create => true) }
    let(:page_a) { FactoryGirl.create(:public_page, :name => 'Page A') }
    let(:page_b) { FactoryGirl.create(:public_page, :name => 'Page B') }
    let(:page_c) { FactoryGirl.create(:public_page, :name => 'Page C', :parent_id => page_b.id) }

    before do
      # to be shure the ordering is alphabetic
      page_b
      page_a
      helper.session[:alchemy_language_id] = 1
    end

    context "with no arguments given" do
      it "should return options for select with all pages ordered by lft" do
        helper.pages_for_select.should match(/option.*Page B.*Page A/m)
      end

      it "should return options for select with nested page names" do
        page_c
        output = helper.pages_for_select
        output.should match(/option.*Startseite.*>&nbsp;&nbsp;Page B.*>&nbsp;&nbsp;&nbsp;&nbsp;Page C.*>&nbsp;&nbsp;Page A/m)
      end
    end

    context "with pages passed in" do
      before do
        @pages = []
        3.times { @pages << FactoryGirl.create(:public_page) }
      end

      it "should return options for select with only these pages" do
        output = helper.pages_for_select(@pages)
        output.should match(/#{@pages.collect(&:name).join('.*')}/m)
        output.should_not match(/Page A/m)
      end

      it "should not nest the page names" do
        output = helper.pages_for_select(@pages)
        output.should_not match(/option.*&nbsp;/m)
      end
    end
  end

  describe '#essence_picture_thumbnail' do
    let(:content) { build_stubbed(:content, essence: build_stubbed(:essence_picture)) }

    it "should return an image tag" do
      expect(helper.essence_picture_thumbnail(content, {})).to have_selector('img[src]')
    end

    context 'when given content has no ingredient' do
      before { content.stub(:ingredient).and_return(nil) }
      it "should return nil" do
        expect(helper.essence_picture_thumbnail(content, {})).to eq(nil)
      end
    end
  end

end
