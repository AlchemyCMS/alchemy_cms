require 'spec_helper'

describe Alchemy::Admin::PagesHelper do
  describe '#preview_sizes_for_select' do
    it "returns a options string of preview screen sizes for select tag" do
      expect(helper.preview_sizes_for_select).to include('option', 'auto', '240', '320', '480', '768', '1024', '1280')
    end
  end

  describe '#page_layout_label' do
    let(:page) { build(:alchemy_page) }

    subject { helper.page_layout_label(page) }

    context 'when page is not yet persisted' do
      it 'displays text only' do
        is_expected.to eq(Alchemy.t(:page_type))
      end
    end

    context 'when page is persited' do
      before { page.save! }

      context 'with page layout existing' do
        it 'displays text only' do
          is_expected.to eq(Alchemy.t(:page_type))
        end
      end

      context 'with page layout definition missing' do
        before do
          expect(page).to receive(:definition).and_return([])
        end

        it 'displays icon with warning and tooltip' do
          is_expected.to have_selector '.icon-warning.with-hint .hint-bubble'
        end
      end
    end
  end
end
