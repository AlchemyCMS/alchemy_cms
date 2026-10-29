# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::TestSupport::CapybaraHelpers do
  subject(:helper) do
    Class.new { include Alchemy::TestSupport::CapybaraHelpers }.new
  end

  describe "#tom_select_search" do
    let(:element) { double(:element, click: nil, send_keys: nil) }

    before do
      allow(helper).to receive(:page).and_return(:whole_page)
      allow(helper).to receive(:within).and_yield
      allow(helper).to receive(:within_entire_page).and_yield
      allow(helper).to receive(:find).and_return(element)
    end

    it "scopes to the whole page when no from/element option is given" do
      helper.tom_select_search("value", {})
      expect(helper).to have_received(:within).with(:whole_page)
    end
  end
end
