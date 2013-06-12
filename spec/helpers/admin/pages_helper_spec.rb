require 'spec_helper'

describe Alchemy::Admin::PagesHelper do

  describe '#sitemap_folder_link' do
    let(:user) { FactoryGirl.build_stubbed(:admin_user) }
    before { helper.stub(:current_user).and_return(user) }
    subject { helper.sitemap_folder_link(page) }

    context "with folded page" do
      let(:page) { mock_model(Alchemy::Page, folded?: true) }

      it "renders a link with folded class" do
        should match /class="page_folder folded"/
      end

      it "renders a link with hide title" do
        should match /title="Show childpages"/
      end
    end

    context "with collapsed page" do
      let(:page) { mock_model(Alchemy::Page, folded?: false) }

      it "renders a link with collapsed class" do
        should match /class="page_folder collapsed"/
      end

      it "renders a link with hide title" do
        should match /title="Hide childpages"/
      end
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
