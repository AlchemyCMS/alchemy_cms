require 'spec_helper'

include Alchemy::BaseHelper

describe Alchemy::ElementsHelper do

  before(:each) do
    @page = Factory(:public_page)
    @element = Factory(:element, :page => @page)
    session[:language_id] = @page.language_id
  end

  it "should render an element view partial" do
    helper.render_element(@element).should match(/id="#{@element.name}_#{@element.id}"/)
  end

  it "should render a unique dom id for element" do
    helper.element_dom_id(@element).should == "#{@element.name}_#{@element.id}"
  end

  describe "#render_elements" do

    before(:each) do
      helper.stub!(:configuration).and_return(true)
    end

    context "with no certain option given" do
      it "should render all elements from @page" do
        @another_element = Factory(:element, :page => @page)
        # m for regex means line breaks are like every character
        helper.render_elements.should match(/id="#{@element.name}_#{@element.id.to_s}.*id="#{@another_element.name}_#{@another_element.id.to_s}"/m)
      end

      it "should not render elements that are in a cell" do
        cell = Factory(:cell)
        @another_element = Factory(:element, :page => @page, :cell_id => cell.id)
        helper.render_elements.should_not match(/id="#{@another_element.name}_#{@another_element.id}"/)
      end
    end

    context "with except option" do
      it "should render all elements except a certain one" do
        @another_element = Factory(:element, :page => @page)
        helper.render_elements(:except => @another_element.name).should_not match(/id="#{@another_element.name}_\d*"/)
      end
    end

    context "with only option" do
      it "should render one certain element" do
        @another_element = Factory(:element, :name => 'headline', :page => @page)
        helper.render_elements(:only => @element.name).should_not match(/id="#{@another_element.name}_\d*"/)
      end
    end

    context "with from_page option" do
      it "should render all elements from a certain page" do
        @another_page = Factory(:public_page)
        @element_on_other_page = Factory(:element, :name => 'headline', :page => @another_page)
        helper.render_elements(:from_page => @another_page).should match(/id="#{@element_on_other_page.name}_\d*"/)
      end

      it "should not render any elements in a cell from the given page" do
        @another_page = Factory(:public_page)
        @cell = Factory(:cell, :name => "Celltest", :page => @another_page)
        @element_not_in_cell = Factory(:element, :name => 'headline', :page => @another_page)
        @element_in_cell = Factory(:element, :name => 'article', :cell => @cell, :page => @another_page)
        helper.render_elements(:from_page => @another_page).should_not match(/id="#{@element_in_cell.name}_#{@element_in_cell.id}*"/)
      end

      context "and from_cell option" do
        it "should render all elements from the page's cell" do
          @another_page = Factory(:public_page)
          @cell = Factory(:cell, :name => "Celltest", :page => @another_page)
          @element_not_in_cell = Factory(:element, :name => 'headline', :page => @another_page)
          @element_in_cell = Factory(:element, :name => 'article', :cell => @cell, :page => @another_page)
          helper.render_elements(:from_page => @another_page, :from_cell => "Celltest").should match(/id="#{@element_in_cell.name}_#{@element_in_cell.id}*"/)
        end
      end

    end

    context "with from_cell option" do
      it "should render all elements from a certain cell" do
        cell = Factory(:cell)
        @another_element = Factory(:element, :page => @page, :cell_id => cell.id)
        helper.render_elements(:from_cell => cell).should match(/id="#{@another_element.name}_#{@another_element.id}"/)
      end

      context "with from_cell and only option" do
        it "should render certain elements from a certain cell" do
          cell = Factory(:cell)
          @another_element = Factory(:element, :page => @page, :cell_id => cell.id)
          @another_element2 = Factory(:element, :page => @page)
          helper.render_elements(:from_cell => cell, :only => @another_element.name).should_not match(/id="#{@another_element2.name}_#{@another_element2.id}"/)
        end
      end

      context "with from_cell and except option" do
        it "should render all elements except certain ones from a certain cell" do
          cell = Factory(:cell)
          @another_element = Factory(:element, :page => @page, :cell_id => cell.id)
          @another_element2 = Factory(:element, :page => @page, :cell_id => cell.id)
          helper.render_elements(:from_cell => cell, :except => @another_element.name).should_not match(/id="#{@another_element.name}_#{@another_element.id}"/)
        end
      end

    end

    context "with count option" do
      it "should render just one element because of the count option" do
        @page.elements.delete_all
        @another_element_1 = Factory(:element, :page => @page)
        @another_element_2 = Factory(:element, :page => @page)
        @another_element_3 = Factory(:element, :page => @page)
        helper.render_elements(:count => 1).should match(/id="#{@another_element_1.name}_#{@another_element_1.id}"/)
      end
    end

    context "with offset option" do
      it "should render all elements beginning with the second." do
        @page.elements.delete_all
        @another_page = Factory(:public_page)
        @another_element_1 = Factory(:element, :page => @page)
        @another_element_2 = Factory(:element, :page => @page)
        @another_element_3 = Factory(:element, :page => @page)
        helper.render_elements(:offset => 1).should_not match(/id="#{@another_element_1.name}_#{@another_element_1.id}"/)
      end
    end

    context "with option fallback" do
      it "should render the fallback element, when no element with the given name is found" do
        @page.elements.delete_all
        @another_element_1 = Factory(:element, :page => @page)
        helper.render_elements(:fallback => {:for => 'foo', :with => @another_element_1.name, :from => @page.page_layout}).should match(/id="#{@another_element_1.name}_#{@another_element_1.id}"/)
      end
    end

  end

  describe "#render_cell_elements" do
    it "should render elements for a cell" do
      cell = Factory(:cell)
      @element_in_cell = Factory(:element, :cell_id => cell.id)
      helper.stub(:configuration).and_return(true)
      helper.render_cell_elements(cell).should match(/id="#{@element_in_cell.name}_#{@element_in_cell.id}"/)
    end
  end

  context "in preview mode" do

    it "should return the data-alchemy-element HTML attribute for element" do
      @preview_mode = true
      helper.element_preview_code(@element).should == " data-alchemy-element='#{@element.id}'"
    end

    it "should not return the data-alchemy-element HTML attribute if not in preview_mode" do
      helper.element_preview_code(@element).should_not == " data-alchemy-element='#{@element.id}'"
    end

  end

end
