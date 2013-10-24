require 'spec_helper'

describe 'alchemy/essences/_essence_boolean_view' do

  context 'with true as ingredient' do
    let(:content) { Alchemy::EssenceBoolean.new(ingredient: true) }
    before { view.stub(:_t).and_return('true') }

    it "renders true" do
      render content, content: content
      expect(rendered).to have_content('true')
    end
  end

  context 'with false as ingredient' do
    let(:content) { Alchemy::EssenceBoolean.new(ingredient: false) }
    before { view.stub(:_t).and_return('false') }

    it "renders false" do
      render content, content: content
      expect(rendered).to have_content('false')
    end
  end

end
