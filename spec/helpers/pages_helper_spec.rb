require 'spec_helper'

describe PagesHelper do

  describe "language_switches" do
    before :each do
      helper.stub(:configuration)
    end

    it "should return links to all other languages" do
      helper.stub(:multi_language?).and_return(true)
      Page.create(:language_code => "en", :public => true)
      Page.create(:language_code => "de")
                                                 ss
      helper.language_switches.should == ""
    end

    it "should return nil if there is only one language" do
      helper.stub(:multi_language?).and_return(nil)
      helper.language_switches.should be nil
    end
  end
end