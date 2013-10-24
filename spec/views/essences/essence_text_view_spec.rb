require 'spec_helper'

describe 'alchemy/essences/_essence_text_view' do
  let(:essence) { Alchemy::EssenceText.new(body: 'Hello World') }
  let(:content) { Alchemy::Content.new(essence: essence) }

  context 'with blank link value' do
    it "only renders the ingredient" do
      render content, content: content
      expect(rendered).to have_content('Hello World')
      expect(rendered).to_not have_selector('a')
    end
  end

  context 'with a link set' do
    let(:essence) { Alchemy::EssenceText.new(body: 'Hello World', link: 'http://google.com', link_title: 'Foo', link_target: 'blank') }

    it "renders the linked ingredient" do
      render content, content: content
      expect(rendered).to have_content('Hello World')
      expect(rendered).to have_selector('a[title="Foo"][target="_blank"][data-link-target="blank"][href="http://google.com"]')
    end

    context 'with html_options given' do
      it "renders the linked with these options" do
        render content, content: content, html_options: {title: 'Bar', class: 'blue'}
        expect(rendered).to have_selector('a.blue[title="Bar"][target="_blank"][data-link-target="blank"]')
      end
    end

    context 'but with options disable_link set to true' do
      it "only renders the ingredient" do
        render content, content: content, options: {disable_link: true}
        expect(rendered).to have_content('Hello World')
        expect(rendered).to_not have_selector('a')
      end
    end
  end

end
