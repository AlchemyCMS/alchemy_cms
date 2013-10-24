require 'spec_helper'

describe 'alchemy/essences/_essence_richtext_view' do
  let(:essence) { Alchemy::EssenceRichtext.new(body: '<h1>Lorem ipsum dolor sit amet</h1> <p>consectetur adipiscing elit.</p>', stripped_body: 'Lorem ipsum dolor sit amet consectetur adipiscing elit.') }
  let(:content) { Alchemy::Content.new(essence: essence) }

  it "renders the html body" do
    render content, content: content
    expect(rendered).to have_content('Lorem ipsum dolor sit amet consectetur adipiscing elit.')
    expect(rendered).to have_selector('h1')
  end

  context 'with options[:plain_text] true' do
    it "renders the text body" do
      render content, content: content, options: {plain_text: true}
      expect(rendered).to have_content('Lorem ipsum dolor sit amet consectetur adipiscing elit.')
      expect(rendered).to_not have_selector('h1')
    end

    context 'and with options[:shorten_to] set to 5' do
      it "renders the text body shortened to 5 words" do
        render content, content: content, options: {plain_text: true, shorten_to: 5}
        expect(rendered).to have_content('Lorem ipsum dolor sit amet')
        expect(rendered).to_not have_content('consectetur adipiscing elit')
        expect(rendered).to_not have_selector('h1')
      end
    end
  end

  context 'with options[:shorten_to] set to 5' do
    it "renders the html body shortened to 5 words" do
      render content, content: content, options: {shorten_to: 5}
      expect(rendered).to have_content('Lorem ipsum dolor sit amet')
      expect(rendered).to_not have_content('consectetur adipiscing elit')
      expect(rendered).to have_selector('h1')
    end

    context 'and with options[:shorten_suffix] set to >' do
      it "renders the html body shortened to 5 words" do
        render content, content: content, options: {shorten_to: 5, shorten_suffix: '>'}
        expect(rendered).to have_content('Lorem ipsum dolor sit amet>')
      end
    end
  end

end
