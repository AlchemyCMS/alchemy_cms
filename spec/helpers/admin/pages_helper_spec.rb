require 'spec_helper'

describe Alchemy::Admin::PagesHelper do

  describe '#sitemap_folder_link' do
    let(:user) { admin_user }

    before { allow(helper).to receive(:current_alchemy_user).and_return(user) }

    subject { helper.sitemap_folder_link(page) }

    context "with folded page" do
      let(:page) { mock_model(Alchemy::Page, folded?: true) }

      it "renders a link with folded class" do
        is_expected.to match /class="page_folder folded spinner"/
      end

      it "renders a link with hide title" do
        is_expected.to match /title="Show childpages"/
      end
    end

    context "with collapsed page" do
      let(:page) { mock_model(Alchemy::Page, folded?: false) }

      it "renders a link with collapsed class" do
        is_expected.to match /class="page_folder collapsed spinner"/
      end

      it "renders a link with hide title" do
        is_expected.to match /title="Hide childpages"/
      end
    end
  end

  describe '#preview_sizes_for_select' do
    it "returns a options string of preview screen sizes for select tag" do
      expect(helper.preview_sizes_for_select).to include('option', 'auto', '240', '320', '480', '768', '1024', '1280')
    end
  end

  describe '#combined_page_status' do
    let(:page) { FactoryGirl.build_stubbed(:page, restricted: true, visible: true, public: true, locked: true) }
    subject { helper.combined_page_status(page) }

    context 'when page is locked' do
      it { is_expected.not_to match(/locked/) } # We don't want the locked status in the return string
    end

    context 'when page is restricted' do
      it { is_expected.to match(/is restricted/) }
    end

    context 'when page is visible in navigation' do
      it { is_expected.to match(/is visible/) }
    end

    context 'when page is published' do
      it { is_expected.to match(/is published/) }
    end
  end

end
