require 'spec_helper'

describe Alchemy::Admin::PagesHelper do

  describe '#tinymce_javascript_tags' do
    it "renders script tag for tinymce initalization" do
      helper.tinymce_javascript_tags.squish.should match(/script.+Alchemy\.Tinymce/)
    end
  end

  describe '#custom_tinymce_javascript_tags' do
    it "renders script tag for custom tinymce initalization" do
      helper.custom_tinymce_javascript_tags.squish.should match(/Alchemy\.Tinymce\.customInits/)
    end
  end

  describe '#preview_sizes_for_select' do
    it "returns a options string of preview screen sizes for select tag" do
      helper.preview_sizes_for_select.should include('option', 'auto', '240', '320', '480', '768', '1024', '1280')
    end
  end

  describe '#combined_page_status' do
    let(:page) { FactoryGirl.build(:page, public: true, visible: true, restricted: false, locked: false)}

    it "returns the translated page status" do
      helper.combined_page_status(page).should == 'Page is visible in navigation.<br>Page is published.<br>Page is not restricted.'
    end
  end

end
