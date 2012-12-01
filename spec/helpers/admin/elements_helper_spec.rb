require 'spec_helper'

include Alchemy::BaseHelper

describe Alchemy::Admin::ElementsHelper do

  context "partial rendering" do

    before do
      @page = FactoryGirl.create(:public_page)
      @element = FactoryGirl.create(:element, :page => @page, :create_contents_after_create => true)
    end

    it "should render an element editor partial" do
      helper.render_editor(@element).should match(/class="essence_text content_editor".+id="essence_text_\d{1,}"/)
    end

    it "should render a picture gallery editor partial" do
      helper.render_picture_gallery_editor(@element).should match(/class=".+picture_gallery_editor"/)
    end

  end

  describe "#grouped_elements_for_select" do

    before do
      @page = FactoryGirl.create(:public_page)
    end

    before(:each) do
      @page.stub!(:layout_description).and_return({'name' => "foo", 'cells' => ["foo_cell"]})
      cell_descriptions = [{'name' => "foo_cell", 'elements' => ["1", "2"]}]
      @elements = [{'name' => '1'}, {'name' => '2'}]
      Alchemy::Cell.stub!(:definitions).and_return(cell_descriptions)
    end

    it "should return string of elements grouped by cell for select_tag helper" do
      helper.grouped_elements_for_select(@elements).should == helper.grouped_options_for_select({"Foo cell" => [["1", "1#foo_cell"], ["2", "2#foo_cell"]]})
    end

    context "with empty elements array" do
      it "should return an empty string" do
        helper.grouped_elements_for_select([]).should == ""
      end
    end

    context "with empty cell definitions" do
      it "should return an empty string" do
        @page.stub!(:layout_description).and_return({'name' => "foo"})
        helper.grouped_elements_for_select(@elements).should == ""
      end
    end

  end

end
