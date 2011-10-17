require 'spec_helper'

describe PagesHelper do

  context "language_switches" do
	
    before :each do
      helper.stub(:configuration)
    end

    it "should return links to all other languages" do
      helper.stub(:multi_language?).and_return(true)
      Page.create(:language_code => "en", :public => true)
      Page.create(:language_code => "de")
      helper.language_switches.should == ""
    end

    it "should return nil if there is only one language" do
      helper.stub(:multi_language?).and_return(nil)
      helper.language_switches.should be nil
    end

	end
	
  context "rendering elements", :focus => true do

		before(:each) do
		  @element = Factory(:element)
		end

    it "should render an element view partial" do
			render_element(@element)
    end

		it "should render a unique dom id for element" do
		  element_dom_id(@element).should == "#{@element.name}_#{@element.id}"
		end

		it "should return the data-alchemy-element HTML attribute for element" do
			@preview_mode = true
		  element_preview_code(@element).should == " data-alchemy-element='#{@element.id}'"
		end

		it "should not return the data-alchemy-element HTML attribute if not in preview_mode" do
		  element_preview_code(@element).should_not == " data-alchemy-element='#{@element.id}'"
		end

  end

end