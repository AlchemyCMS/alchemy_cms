require "rails_helper"

RSpec.describe Alchemy::Admin::FormHelper do
  describe "#alchemy_form_for" do
    subject { helper.alchemy_form_for(resource) {} }

    let(:resource) do
      [alchemy, :admin, Alchemy::Element.new(name: "article")]
    end

    it "returns a form with alchemy class" do
      expect(subject).to have_css(".alchemy")
    end

    it "enables browser validations" do
      expect(subject).not_to have_css("form[novalidate]")
    end
  end
end
