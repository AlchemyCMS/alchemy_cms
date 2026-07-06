# frozen_string_literal: true

require "rails_helper"
require "alchemy/upgrader"

RSpec.describe Alchemy::Upgrader::EightFour do
  let(:upgrader) { Alchemy::Upgrader["8.4"] }

  around do |example|
    Alchemy::Shell.silence!
    example.run
    Alchemy::Shell.verbose!
  end

  describe "#add_dragonfly_gem" do
    subject { upgrader.add_dragonfly_gem }

    context "when the storage adapter is dragonfly" do
      before do
        allow(Alchemy).to receive(:storage_adapter) do
          Alchemy::StorageAdapter.new(:dragonfly)
        end
      end

      it "adds the dragonfly gem to the bundle" do
        expect(upgrader).to receive(:run).with(%(bundle add dragonfly --version "~> 1.4"))
        subject
      end
    end

    context "when the storage adapter is active_storage" do
      before do
        allow(Alchemy).to receive(:storage_adapter) do
          Alchemy::StorageAdapter.new(:active_storage)
        end
      end

      it "does not add the dragonfly gem" do
        expect(upgrader).not_to receive(:run)
        subject
      end
    end
  end
end
