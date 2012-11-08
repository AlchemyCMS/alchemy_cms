require 'spec_helper'

module Alchemy
  describe BaseHelper do

    describe "#render_message" do

      context "if no argument is passed" do
        it "should render a div with an info icon and the given content" do
          helper.render_message{ content_tag(:p, "my notice") }.should match(/<div class="info message"><span class="icon info"><\/span><p>my notice/)
        end
      end

      context "if an argument is passed" do
        it "should render the passed argument as the css classname for the icon container" do
          helper.render_message(:error){ content_tag(:p, "my notice") }.should match(/<div class="error message"><span class="icon error">/)
        end
      end

    end

    describe "#configuration" do
      it "should return certain configuration options" do
        Config.stub!(:show).and_return({"some_option" => true})
        helper.configuration(:some_option).should == true
      end
    end

    describe "#multi_language?" do

      context "if more than one published language exists" do
        it "should return true" do
          Alchemy::Language.stub_chain(:published, :count).and_return(2)
          helper.multi_language?.should == true
        end
      end

      context "if less than two published languages exists" do
        it "should return false" do
          Alchemy::Language.stub_chain(:published, :count).and_return(1)
          helper.multi_language?.should == false
        end
      end

    end

  end
end
