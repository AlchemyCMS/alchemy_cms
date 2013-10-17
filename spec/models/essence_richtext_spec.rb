require 'spec_helper'

module Alchemy
  describe EssenceRichtext do

    it "should save a HTML tag free version of body column" do
      essence = EssenceRichtext.new(:body => '<h1>Hello!</h1><p>Welcome to Peters Petshop.</p>')
      essence.save
      essence.stripped_body.should == "Hello!Welcome to Peters Petshop."
    end

  end
end
