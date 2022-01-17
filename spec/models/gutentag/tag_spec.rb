# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gutentag::Tag do
  describe "validations" do
    let!(:tag_1) { described_class.create(name: "red") }
    let(:tag_2) { described_class.new(name: "Red") }

    it "should allow tags with different case" do
      expect(tag_2).to be_valid
    end
  end
end
