# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::SearchableResource do
  let(:klass) do
    Class.new
  end

  before do
    klass.extend described_class
  end

  subject { klass }

  describe ".ransackable_scopes" do
    subject { klass.ransackable_scopes }

    it { is_expected.to be_empty }

    context "with resource filters defined" do
      let(:klass) do
        Class.new do
          # dummy scopes
          def self.starting_today
          end

          def self.future
          end

          def self.by_timeframe(by_timeframe)
          end

          def self.alchemy_resource_filters
            [
              {
                name: :start,
                values: %w[starting_today future]
              },
              {
                name: :by_timeframe,
                values: [:today, :in_the_past]
              }
            ]
          end
        end
      end

      it { is_expected.to match_array %w[starting_today future by_timeframe] }
    end
  end
end
