require 'spec_helper'

describe 'alchemy/essences/_essence_date_view' do
  let(:essence) { Alchemy::EssenceDate.new(date: '2013-10-27 21:14:16 +0100'.to_datetime) }
  let(:content) { Alchemy::Content.new(essence: essence) }
  let(:options) { {} }

  before do
    view.stub(:options).and_return(options)
  end

  context "with date value" do
    context 'without date_format passed' do
      it "translates the date value with default format" do
        render content, content: content
        expect(rendered).to have_content('Sun, 27 Oct 2013 20:14:16 +0000')
      end
    end

    context 'with option date_format set to rfc822' do
      let(:options) { {date_format: 'rfc822'} }

      it "renders the date rfc822 conform" do
        render content, content: content
        expect(rendered).to have_content('Sun, 27 Oct 2013 20:14:16 +0000')
      end
    end
  end

  context 'with blank date value' do
    let(:essence) { Alchemy::EssenceDate.new(date: nil) }

    it "renders nothing" do
      render content, content: content
      expect(rendered).to eq('')
    end
  end

end
