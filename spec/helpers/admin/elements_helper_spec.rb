require 'spec_helper'

module Alchemy
  describe Admin::ElementsHelper do

    let(:page)    { build_stubbed(:public_page) }
    let(:element) { build_stubbed(:element, page: page) }

    context "partial rendering" do
      it "should render an element editor partial" do
        should_receive(:render_element).with(element, :editor)
        render_editor(element)
      end

      it "should render a picture gallery editor partial" do
        render_picture_gallery_editor(element).should match(/class=".+picture_gallery_editor"/)
      end
    end

    describe "#grouped_elements_for_select" do
      let(:elements) {
        [
          mock_model('Element', name: '1', display_name: '1'),
          mock_model('Element', name: '2', display_name: '2')
        ]
      }

      before do
        page.stub(layout_description: {'name' => "foo", 'cells' => ["foo_cell", "empty_cell"]})
        cell_descriptions = [
          {'name' => "foo_cell", 'elements' => ["1", "2"]},
          {'name' => 'empty_cell', 'elements' => []}
        ]
        Cell.stub(:definitions).and_return(cell_descriptions)
        helper.instance_variable_set('@page', page)
      end

      it "should return array of elements grouped by cell for select_tag helper" do
        helper.grouped_elements_for_select(elements).should include("Foo cell" => [["1", "1#foo_cell"], ["2", "2#foo_cell"]])
      end

      context "with empty elements array" do
        it "should return an empty string" do
          helper.grouped_elements_for_select([]).should == ""
        end
      end

      context "with empty cell definitions" do
        it "should return an empty string" do
          page.stub(layout_description: {'name' => "foo"})
          helper.grouped_elements_for_select(elements).should == ""
        end
      end

      context "with cell having no elements" do
        it "should remove that cell from hash" do
          expect(helper.grouped_elements_for_select(elements)['Empty cell']).to be_nil
        end
      end
    end

    describe "#elements_for_select" do
      context "passing element instances" do
        let(:element_objects) do
          [
            mock_model('Element', name: 'element_1', display_name: 'Element 1'),
            mock_model('Element', name: 'element_2', display_name: 'Element 2')
          ]
        end

        it "should return a array for option tags" do
          helper.elements_for_select(element_objects).should include(['Element 1', 'element_1'])
          helper.elements_for_select(element_objects).should include(['Element 2', 'element_2'])
        end
      end

      context "passing a hash with element descriptions" do
        let(:element_descriptions) do
          [{
            'name' => 'headline',
            'contents' => []
          }]
        end

        subject { helper.elements_for_select(element_descriptions) }

        it "should return a array for option tags" do
          subject.should include(['Headline', 'headline'])
        end

        it "should render the elements display name" do
          Element.should_receive(:display_name_for).with('headline')
          subject
        end
      end
    end
  end
end
