require 'spec_helper'

describe Alchemy::Admin::PagesHelper do

  describe '#combined_page_status' do
    let(:page) { FactoryGirl.build(:page, public: true, visible: true, restricted: false, locked: false)}

    it "returns the translated page status" do
      helper.combined_page_status(page).should == 'Page is visible in navigation.<br>Page is published.<br>Page is not restricted.'
    end
  end

end
