require 'spec_helper'
include Alchemy::BaseHelper

module Alchemy
  describe ElementsHelper do
    let(:page)    { build_stubbed(:public_page) }
    let(:element) { build_stubbed(:element, page: page) }

    before do
      assign(:page, page)
      Element.any_instance.stub(store_page: true)
    end

    describe '#render_element' do
      subject { helper.render_element(element) }

      it "should render an element view partial" do
        should have_selector("##{element.name}_#{element.id}")
      end
    end

    describe '#element_dom_id' do
      subject { helper.element_dom_id(element) }

      it "should render a unique dom id for element" do
        should == "#{element.name}_#{element.id}"
      end
    end

    describe "#render_elements" do
      subject { helper.render_elements(options) }

      let(:another_element) { build_stubbed(:element, page: page) }
      let(:elements)        { [element, another_element] }

      context 'without any options' do
        let(:options) { {} }

        before do
          page.should_receive(:find_elements).and_return(elements)
        end

        it "should render all elements from page." do
          should have_selector("##{element.name}_#{element.id}")
          should have_selector("##{another_element.name}_#{another_element.id}")
        end
      end

      context "with from_page option" do
        context 'is a page object' do
          let(:another_page) { build_stubbed(:public_page) }
          let(:options)      { {from_page: another_page} }

          before do
            another_page.should_receive(:find_elements).and_return(elements)
          end

          it "should render all elements from that page." do
            should have_selector("##{element.name}_#{element.id}")
            should have_selector("##{another_element.name}_#{another_element.id}")
          end
        end

        context 'is a string' do
          let(:another_page)    { build_stubbed(:public_page) }
          let(:another_element) { build_stubbed(:element, page: another_page) }
          let(:other_elements)  { [another_element] }
          let(:options)         { {from_page: 'news'} }

          before do
            array = double
            array.should_receive(:to_a).and_return(pages)
            Page.should_receive(:where).and_return(array)
            another_page.should_receive(:find_elements).and_return(other_elements)
          end

          context 'and one page can be found by page layout' do
            let(:pages) { [another_page] }

            it "it renders all elements from that page." do
              should have_selector("##{another_element.name}_#{another_element.id}")
            end
          end

          context 'and an array of pages has been found' do
            let(:pages)           { [page, another_page] }

            before do
              page.should_receive(:find_elements).and_return(elements)
            end

            it 'renders elements from these pages' do
              should have_selector("##{element.name}_#{element.id}")
              should have_selector("##{another_element.name}_#{another_element.id}")
            end
          end
        end
      end

      context 'if page is nil' do
        let(:options) { {from_page: nil} }
        it { should be_blank }
      end

      context 'with sort_by option given' do
        let(:options)         { {sort_by: 'title'} }
        let(:sorted_elements) { [another_element, element] }

        before do
          elements.should_receive(:sort_by).and_return(sorted_elements)
          page.should_receive(:find_elements).and_return(elements)
        end

        it "renders the elements in the order of given content name" do
          should_not be_blank
        end
      end

      context "with option fallback" do
        let(:another_page)    { build_stubbed(:public_page, name: 'Another Page', page_layout: 'news') }
        let(:another_element) { build_stubbed(:element, page: another_page, name: 'news') }
        let(:elements)        { [another_element] }

        context 'with string given as :fallback_from' do
          let(:options) { {fallback: {for: 'higgs', with: 'news', from: 'news'}} }

          before do
            Page.should_receive(:find_by).and_return(another_page)
            another_page.stub_chain(:elements, :named).and_return(elements)
          end

          it "renders the fallback element" do
            should have_selector("#news_#{another_element.id}")
          end
        end

        context 'with page given as :fallback_from' do
          let(:options) { {fallback: {for: 'higgs', with: 'news', from: another_page}} }

          before do
            another_page.stub_chain(:elements, :named).and_return(elements)
          end

          it "renders the fallback element" do
            should have_selector("#news_#{another_element.id}")
          end
        end
      end

      context 'with option separator given' do
        let(:options) { {separator: '<hr>'} }

        before do
          page.should_receive(:find_elements).and_return(elements)
        end

        it "joins element partials with given string" do
          should have_selector('hr')
        end
      end
    end

    describe "#render_cell_elements" do
      subject { helper.render_cell_elements(cell) }

      context 'with cell given' do
        let(:cell)            { build_stubbed(:cell) }
        let(:element_in_cell) { build_stubbed(:element, cell: cell) }

        before do
          page.should_receive(:find_elements).and_return([element_in_cell])
        end

        it "renders elements from cell." do
          should have_selector("##{element_in_cell.name}_#{element_in_cell.id}")
        end
      end

      context 'if cell is nil' do
        let(:cell) { nil }
        it { should be_blank }
      end
    end

    describe '#element_preview_code_attributes' do
      subject { helper.element_preview_code_attributes(element) }

      context 'in preview_mode' do
        before { assign(:preview_mode, true) }

        it "should return the data-alchemy-element HTML attribute for element" do
          should == {:'data-alchemy-element' => element.id}
        end
      end

      context 'not in preview_mode' do
        it "should return an empty hash" do
          should == {}
        end
      end
    end

    describe '#element_preview_code' do
      subject { helper.element_preview_code(element) }

      context 'in preview_mode' do
        before { assign(:preview_mode, true) }

        it "should return the data-alchemy-element HTML attribute for element" do
          should == " data-alchemy-element=\"#{element.id}\""
        end
      end

      context 'not in preview_mode' do
        it "should not return the data-alchemy-element HTML attribute" do
          should_not == " data-alchemy-element=\"#{element.id}\""
        end
      end
    end

    describe '#element_tags' do
      subject { helper.element_tags(element, options) }

      let(:options) { {} }

      context "element having tags" do
        before { element.tag_list = "peter, lustig" }

        context "with no formatter lambda given" do
          it "should return tag list as HTML data attribute" do
            should == " data-element-tags=\"peter lustig\""
          end
        end

        context "with a formatter lambda given" do
          let(:options) { {formatter: ->(tags) { tags.join ", " }} }

          it "should return a properly formatted HTML data attribute" do
            should == " data-element-tags=\"peter, lustig\""
          end
        end
      end

      context "element not having tags" do
        it { should be_blank }
      end
    end

    describe '#all_elements_by_name' do
      subject { helper.all_elements_by_name(name, options) }

      let(:page)    { mock_model('Page', language_id: 1) }
      let(:element) { mock_model('Element') }
      let(:name)    { 'el_name' }
      let(:options) { {} }

      context 'found by name' do
        it "should return all public elements" do
          Element.stub_chain(:published, :where, :limit).and_return([element])
          should eq([element])
        end
      end

      context 'if element not found' do
        let(:name) { 'not_existing_name' }
        it { should be_empty }
      end

      context "options[:from_page] is passed" do
        before do
          Page.stub_chain(:with_language, :find_by_page_layout).and_return(page)
          page.stub_chain(:elements, :published, :where, :limit).and_return([element])
        end

        context "as a String" do
          let(:options) { {from_page: 'layout_name'} }

          it "should return all elements associated with the page found by the given layout name" do
            should eq([element])
          end
        end

        context "as a Page object" do
          let(:options) { {from_page: page} }

          it "should return all elements associated with this given page" do
            should eq([element])
          end
        end
      end
    end

    describe '#element_from_page' do
      subject { helper.element_from_page(options) }

      let(:page)    { mock_model('Page', urlname: 'page-1', language_id: 1) }
      let(:element) { mock_model('Element', name: 'el_name') }

      before do
        page.stub_chain(:elements, :published, :find_by_name).and_return(element)
      end

      context "options[:page_urlname] and options[:element_name] is passed" do
        let(:options) { {element_name: element.name, page_urlname: page.urlname} }

        before do
          Page.stub_chain(:published, :find_by_urlname).and_return(page)
        end

        it "should return the element with the given name" do
          should eq(element)
        end
      end

      context "options[:page_id] and options[:element_name] is passed" do
        let(:options) { {element_name: element.name, page_id: page.id} }

        before do
          Page.stub_chain(:published, :find_by_id).and_return(page)
        end

        it "should return the element with the given name" do
          should eq(element)
        end
      end
    end

    describe '#sort_elements_by_content' do
      subject { sort_elements_by_content(elements, 'headline') }

      let(:element_1)    { build_stubbed(:element) }
      let(:element_2)    { build_stubbed(:element) }
      let(:element_3)    { build_stubbed(:element) }
      let(:ingredient_a) { double(ingredient: 'a') }
      let(:ingredient_b) { double(ingredient: 'b') }
      let(:ingredient_c) { double(ingredient: 'c') }
      let(:elements)     { [element_1, element_2, element_3] }

      before do
        element_1.should_receive(:content_by_name).and_return(ingredient_b)
        element_2.should_receive(:content_by_name).and_return(ingredient_c)
        element_3.should_receive(:content_by_name).and_return(ingredient_a)
      end

      it "sorts the elements by content" do
        should eq [element_3, element_1, element_2]
      end

      context 'with element not having this content' do
        let(:element_4) { build_stubbed(:element) }
        let(:elements)  { [element_1, element_2, element_3, element_4] }

        before do
          element_4.should_receive(:content_by_name).and_return(nil)
        end

        it "puts it at first place" do
          should eq [element_4, element_3, element_1, element_2]
        end
      end

      context 'with element having content with nil as ingredient' do
        let(:element_4) { build_stubbed(:element) }
        let(:elements)  { [element_1, element_2, element_3, element_4] }

        before do
          element_4.should_receive(:content_by_name).and_return(double(ingredient: nil))
        end

        it "puts it at first place" do
          should eq [element_4, element_3, element_1, element_2]
        end
      end
    end

  end
end
