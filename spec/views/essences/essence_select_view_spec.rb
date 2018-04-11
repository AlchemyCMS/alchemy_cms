# frozen_string_literal: true

require 'spec_helper'

describe 'alchemy/essences/_essence_select_view' do
  let(:content) { Alchemy::Content.new(essence: essence) }
  let(:essence) { Alchemy::EssenceSelect.new(ingredient: 'blue') }

  it "renders the ingredient" do
    render content, content: content
    expect(rendered).to have_content('blue')
  end
end
