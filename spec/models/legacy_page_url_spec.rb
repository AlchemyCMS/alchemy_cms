require 'spec_helper'

describe Alchemy::LegacyPageUrl do
  let(:page) { build_stubbed(:page) }

  let(:page_url_with_parameters) do
    Alchemy::LegacyPageUrl.new(urlname: 'index.php?id=2', page: page)
  end

  let(:valid_page_url) do
    Alchemy::LegacyPageUrl.new(urlname: 'my/0-work+is-nice_stuff', page: page)
  end

  it 'is only valid with correct urlname format' do
    valid_page_url.should be_valid
  end

  it 'is also valid with get parameters in urlname' do
    page_url_with_parameters.should be_valid
  end
end
