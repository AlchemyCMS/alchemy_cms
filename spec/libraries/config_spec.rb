require 'spec_helper'

describe Alchemy::Config do
  it "should have an array of fields for mailer" do
    Alchemy::Config.get(:mailer)['fields'].should be_a(Array)
  end
end
