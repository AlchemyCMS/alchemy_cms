# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Configuration::PathnameOption do
  subject { described_class.new(value:, name: :my_option).value }

  let(:value) { Rails.root }

  it { is_expected.to be_a(Pathname) }
end
