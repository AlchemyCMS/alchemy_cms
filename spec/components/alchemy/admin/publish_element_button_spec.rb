# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::PublishElementButton, type: :component do
  let(:element) { build_stubbed(:alchemy_element) }
  let(:component) { described_class.new(element:) }

  before do
    allow(vc_test_view_context).to receive(:alchemy_form_for) { "form" }
  end

  context "a scheduled element" do
    before do
      allow(element).to receive(:scheduled?) { true }
    end

    context "with public_on being nil" do
      let(:element) { build_stubbed(:alchemy_element, public_on: nil) }

      it "does not raise an Argument Error" do
        expect { render_inline component }.to_not raise_error
      end
    end
  end
end
