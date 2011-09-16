require 'spec_helper'

describe Language do

  before(:each) do
    @language = Factory(:language)
  end

  it "should return a label for code" do
    @language.label(:code).should == 'kl'
  end

  it "should return a label for name" do
    @language.label(:name).should == 'Klingonian'
  end

end
