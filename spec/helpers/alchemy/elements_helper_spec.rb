# frozen_string_literal: true

require 'spec_helper'
include Alchemy::BaseHelper

module Alchemy
  describe ElementsHelper do
    let(:page)    { build_stubbed(:alchemy_page, :public) }
    let(:element) { build_stubbed(:alchemy_element, name: 'headline', page: page) }

    before do
      assign(:page, page)
      allow_any_instance_of(Element).to receive(:store_page).and_return(true)
    end

    describe '#render_element' do
      subject { render_element(element, part) }

      context 'with nil element' do
        let(:element) { nil }
        let(:part)    { :view }
        it { is_expected.to be_nil }
      end

      context 'with view as part given' do
        let(:part) { :view }

        it "renders the element's view partial" do
          is_expected.to have_selector("##{element.name}_#{element.id}")
        end

        context 'with element view partial not found' do
          let(:element) { build_stubbed(:alchemy_element, name: 'not_present') }

          it "renders the view not found partial" do
            is_expected.to match(/Missing view for not_present element/)
          end
        end
      end

      context 'with editor as part given' do
        let(:part) { :editor }

        it "renders the element's editor partial" do
          expect(helper).to receive(:render_essence_editor_by_name)
          subject
        end

        context 'with element editor partial not found' do
          let(:element) { build_stubbed(:alchemy_element, name: 'not_present') }

          it "renders the editor not found partial" do
            is_expected.to have_selector('div.warning')
            is_expected.to have_content('Element editor partial not found')
          end
        end
      end
    end

    describe '#element_dom_id' do
      subject { helper.element_dom_id(element) }

      it "should render a unique dom id for element" do
        is_expected.to eq("#{element.name}_#{element.id}")
      end
    end

    describe "#render_elements" do
      subject { helper.render_elements(options) }

      let(:another_element) { build_stubbed(:alchemy_element, page: page) }
      let(:elements)        { [element, another_element] }

      context 'without any options' do
        let(:options) { {} }

        before do
          expect(page).to receive(:find_elements).and_return(elements)
        end

        it "should render all elements from page." do
          is_expected.to have_selector("##{element.name}_#{element.id}")
          is_expected.to have_selector("##{another_element.name}_#{another_element.id}")
        end
      end

      context "with from_page option" do
        context 'is a page object' do
          let(:another_page) { build_stubbed(:alchemy_page, :public) }
          let(:options)      { {from_page: another_page} }

          before do
            expect(another_page).to receive(:find_elements).and_return(elements)
          end

          it "should render all elements from that page." do
            is_expected.to have_selector("##{element.name}_#{element.id}")
            is_expected.to have_selector("##{another_element.name}_#{another_element.id}")
          end
        end

        context 'is a string' do
          let(:another_page)    { build_stubbed(:alchemy_page, :public) }
          let(:another_element) { build_stubbed(:alchemy_element, page: another_page) }
          let(:other_elements)  { [another_element] }
          let(:options)         { {from_page: 'news'} }

          before do
            allow(Language).to receive(:current).and_return double(pages: double(where: pages))
            expect(another_page).to receive(:find_elements).and_return(other_elements)
          end

          context 'and one page can be found by page layout' do
            let(:pages) { [another_page] }

            it "it renders all elements from that page." do
              is_expected.to have_selector("##{another_element.name}_#{another_element.id}")
            end
          end

          context 'and an array of pages has been found' do
            let(:pages) { [page, another_page] }

            before do
              expect(page).to receive(:find_elements).and_return(elements)
            end

            it 'renders elements from these pages' do
              is_expected.to have_selector("##{element.name}_#{element.id}")
              is_expected.to have_selector("##{another_element.name}_#{another_element.id}")
            end
          end
        end
      end

      context 'if page is nil' do
        let(:options) { {from_page: nil} }
        it { is_expected.to be_blank }
      end

      context 'with sort_by and reverse option given' do
        let(:options)           { {sort_by: true, reverse: true} }
        let(:sorted_elements) { [another_element, element] }

        before do
          expect(elements).to receive(:sort_by).and_return(sorted_elements)
          expect(sorted_elements).to receive(:reverse).and_return(elements)
          expect(page).to receive(:find_elements).and_return(elements)
        end

        it "renders the sorted elements in reverse order" do
          is_expected.not_to be_blank
        end
      end

      context 'with sort_by option given' do
        let(:options)         { {sort_by: 'title'} }
        let(:sorted_elements) { [another_element, element] }

        before do
          expect(elements).to receive(:sort_by).and_return(sorted_elements)
          expect(elements).not_to receive(:reverse)
          expect(page).to receive(:find_elements).and_return(elements)
        end

        it "renders the elements in the order of given content name" do
          is_expected.not_to be_blank
        end
      end

      context "with option fallback" do
        let(:another_page)    { build_stubbed(:alchemy_page, :public, name: 'Another Page', page_layout: 'news') }
        let(:another_element) { build_stubbed(:alchemy_element, page: another_page, name: 'news') }
        let(:elements)        { [another_element] }

        context 'with string given as :fallback_from' do
          let(:options) { {fallback: {for: 'higgs', with: 'news', from: 'news'}} }

          before do
            allow(Language).to receive(:current).and_return double(pages: double(find_by: another_page))
            allow(another_page).to receive(:elements).and_return double(not_trashed: double(named: elements))
          end

          it "renders the fallback element" do
            is_expected.to have_selector("#news_#{another_element.id}")
          end
        end

        context 'with page given as :fallback_from' do
          let(:options) { {fallback: {for: 'higgs', with: 'news', from: another_page}} }

          before do
            allow(another_page).to receive(:elements).and_return double(not_trashed: double(named: elements))
          end

          it "renders the fallback element" do
            is_expected.to have_selector("#news_#{another_element.id}")
          end
        end
      end

      context 'with option separator given' do
        let(:options) { {separator: '<hr>'} }

        before do
          expect(page).to receive(:find_elements).and_return(elements)
        end

        it "joins element partials with given string" do
          is_expected.to have_selector('hr')
        end
      end
    end

    describe '#element_preview_code_attributes' do
      subject { helper.element_preview_code_attributes(element) }

      context 'in preview_mode' do
        before { assign(:preview_mode, true) }

        it "should return the data-alchemy-element HTML attribute for element" do
          is_expected.to eq({'data-alchemy-element' => element.id})
        end
      end

      context 'not in preview_mode' do
        it "should return an empty hash" do
          is_expected.to eq({})
        end
      end
    end

    describe '#element_preview_code' do
      subject { helper.element_preview_code(element) }

      context 'in preview_mode' do
        before { assign(:preview_mode, true) }

        it "should return the data-alchemy-element HTML attribute for element" do
          is_expected.to eq(" data-alchemy-element=\"#{element.id}\"")
        end
      end

      context 'not in preview_mode' do
        it "should not return the data-alchemy-element HTML attribute" do
          is_expected.not_to eq(" data-alchemy-element=\"#{element.id}\"")
        end
      end
    end

    describe '#element_tags' do
      subject { element_tags(element, options) }

      let(:element) { build_stubbed(:alchemy_element) }
      let(:options) { {} }

      context "element having tags" do
        before { element.tag_list = "peter, lustig" }

        context "with no formatter lambda given" do
          it "should return tag list as HTML data attribute" do
            is_expected.to eq(" data-element-tags=\"peter lustig\"")
          end
        end

        context "with a formatter lambda given" do
          let(:options) { {formatter: ->(tags) { tags.join ", " }} }

          it "should return a properly formatted HTML data attribute" do
            is_expected.to eq(" data-element-tags=\"peter, lustig\"")
          end
        end
      end

      context "element not having tags" do
        it { is_expected.to be_blank }
      end
    end

    describe '#sort_elements_by_content' do
      subject { sort_elements_by_content(elements, 'headline') }

      let(:element_1)    { build_stubbed(:alchemy_element) }
      let(:element_2)    { build_stubbed(:alchemy_element) }
      let(:element_3)    { build_stubbed(:alchemy_element) }
      let(:ingredient_a) { double(ingredient: 'a') }
      let(:ingredient_b) { double(ingredient: 'b') }
      let(:ingredient_c) { double(ingredient: 'c') }
      let(:elements)     { [element_1, element_2, element_3] }

      before do
        expect(element_1).to receive(:content_by_name).and_return(ingredient_b)
        expect(element_2).to receive(:content_by_name).and_return(ingredient_c)
        expect(element_3).to receive(:content_by_name).and_return(ingredient_a)
      end

      it "sorts the elements by content" do
        is_expected.to eq [element_3, element_1, element_2]
      end

      context 'with element not having this content' do
        let(:element_4) { build_stubbed(:alchemy_element) }
        let(:elements)  { [element_1, element_2, element_3, element_4] }

        before do
          expect(element_4).to receive(:content_by_name).and_return(nil)
        end

        it "puts it at first place" do
          is_expected.to eq [element_4, element_3, element_1, element_2]
        end
      end

      context 'with element having content with nil as ingredient' do
        let(:element_4) { build_stubbed(:alchemy_element) }
        let(:elements)  { [element_1, element_2, element_3, element_4] }

        before do
          expect(element_4).to receive(:content_by_name).and_return(double(ingredient: nil))
        end

        it "puts it at first place" do
          is_expected.to eq [element_4, element_3, element_1, element_2]
        end
      end
    end
  end
end
