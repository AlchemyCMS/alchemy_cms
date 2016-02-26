require 'spec_helper'

describe 'alchemy/essences/_essence_select_view' do
  let(:essence) { Alchemy::EssenceSelect.new(value: 'blue') }

  let(:content) do
    Alchemy::Content.new(essence: essence, essence_data: {'value' => essence.value})
  end

  it "renders the ingredient" do
    render content, content: content
    expect(rendered).to have_content('blue')
  end
end
