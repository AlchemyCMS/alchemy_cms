# frozen_string_literal: true

require 'spec_helper'

describe Alchemy::Admin::EssencesHelper do
  include Alchemy::Admin::ElementsHelper

  let(:element) do
    create(:alchemy_element, name: 'article', create_contents_after_create: true)
  end

  describe 'essence rendering' do
    before do
      if element
        element.content_by_name('intro').essence.update(body: 'hello!')
      end
    end

    describe '#render_essence_editor' do
      it "should render an essence editor" do
        content = element.content_by_name('intro')
        expect(helper.render_essence_editor(content)).
          to match(/input.+type="text".+value="hello!/)
      end
    end

    describe '#render_essence_editor_by_name' do
      subject { render_essence_editor_by_name(element, content) }

      let(:content) { 'intro' }

      it "renders an essence editor by given name" do
        is_expected.to match(/input.+type="text".+value="hello!/)
      end

      context 'when element is nil' do
        let(:element) { nil }

        it "displays a warning" do
          is_expected.to have_selector(".content_editor_error")
          is_expected.to have_content("No element given.")
        end
      end

      context 'when content is not found on element' do
        let(:content) { 'sputz' }

        it "displays a warning" do
          is_expected.to have_selector(".content_editor.missing")
        end
      end
    end
  end

  describe '#pages_for_select' do
    let(:contact_form) do
      create(:alchemy_element, name: 'contactform', create_contents_after_create: true)
    end

    let(:page_a) { create(:alchemy_page, :public, name: 'Page A') }
    let(:page_b) { create(:alchemy_page, :public, name: 'Page B') }
    let(:page_c) { create(:alchemy_page, :public, name: 'Page C', parent_id: page_b.id) }

    before do
      # to be shure the ordering is alphabetic
      page_b
      page_a
      helper.session[:alchemy_language_id] = 1
    end

    context "with no arguments given" do
      it "should return options for select with all pages ordered by lft" do
        expect(helper.pages_for_select).to match(/option.*Page B.*Page A/m)
      end

      it "should return options for select with nested page names" do
        page_c
        output = helper.pages_for_select
        expect(output).to match(/option.*Startseite.*>&nbsp;&nbsp;Page B.*>&nbsp;&nbsp;&nbsp;&nbsp;Page C.*>&nbsp;&nbsp;Page A/m)
      end
    end

    context "with pages passed in" do
      before do
        @pages = []
        3.times { @pages << create(:alchemy_page, :public) }
      end

      it "should return options for select with only these pages" do
        output = helper.pages_for_select(@pages)
        expect(output).to match(/#{@pages.collect(&:name).join('.*')}/m)
        expect(output).not_to match(/Page A/m)
      end

      it "should not nest the page names" do
        output = helper.pages_for_select(@pages)
        expect(output).not_to match(/option.*&nbsp;/m)
      end
    end
  end

  describe '#essence_picture_thumbnail' do
    let(:essence) do
      build_stubbed(:alchemy_essence_picture)
    end

    let(:content) do
      build_stubbed(:alchemy_content, essence: essence)
    end

    before do
      allow(essence).to receive(:content) { content }
    end

    it "should return an image tag with thumbnail url from essence" do
      expect(essence).to receive(:thumbnail_url).and_call_original
      expect(helper.essence_picture_thumbnail(content)).to \
        have_selector("img[src].img_paddingtop")
    end

    context 'when given content has no ingredient' do
      before { allow(content).to receive(:ingredient).and_return(nil) }

      it "should return nil" do
        expect(helper.essence_picture_thumbnail(content)).to eq(nil)
      end
    end
  end

  describe "#edit_picture_dialog_size" do
    let(:content) { build_stubbed(:alchemy_content) }

    subject { edit_picture_dialog_size(content) }

    context "with content having setting caption_as_textarea being true and sizes set" do
      before do
        allow(content).to receive(:settings) do
          {
            caption_as_textarea: true,
            sizes: ['100x100', '200x200']
          }
        end

        it { is_expected.to eq("380x320") }
      end
    end

    context "with content having setting caption_as_textarea being true and no sizes set" do
      before do
        allow(content).to receive(:settings) do
          {
            caption_as_textarea: true
          }
        end

        it { is_expected.to eq("380x300") }
      end
    end

    context "with content having setting caption_as_textarea being false and sizes set" do
      before do
        allow(content).to receive(:settings) do
          {
            caption_as_textarea: false,
            sizes: ['100x100', '200x200']
          }
        end

        it { is_expected.to eq("380x290") }
      end
    end

    context "with content having setting caption_as_textarea being false and no sizes set" do
      before do
        allow(content).to receive(:settings) do
          {
            caption_as_textarea: false
          }
        end

        it { is_expected.to eq("380x255") }
      end
    end
  end
end
