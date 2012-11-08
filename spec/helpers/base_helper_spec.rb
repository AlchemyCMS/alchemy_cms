require 'spec_helper'

describe Alchemy::BaseHelper do

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

end
