require 'spec_helper'

describe PagesHelper do

  context "rendering elements" do

		before(:each) do
		  @element = Factory(:element)
		end

    it "should render an element view partial" do
      render_element(@element)
    end

  end

end
