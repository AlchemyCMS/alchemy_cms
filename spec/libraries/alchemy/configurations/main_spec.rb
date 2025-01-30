# frozen_string_literal: true

require "rails_helper"
require "alchemy/configurations/main"

RSpec.describe Alchemy::Configurations::Main do
  let(:fixture_file) do
    Rails.root.join("..", "fixtures", "config.yml")
  end

  subject { described_class.new }

  before { subject.set_from_yaml(fixture_file) }

  it "has data from the yaml file" do
    expect(subject.auto_logout_time).to eq(20)
  end
end
