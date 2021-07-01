# frozen_string_literal: true

require "rails_helper"

module Alchemy
  shared_examples_for "having a hint" do
    describe "#hint" do
      context "with hint as text" do
        before do
          expect(subject).to receive(:definition).and_return({ hint: "The hint" })
        end

        it "returns the hint" do
          expect(subject.hint).to eq("The hint")
        end
      end

      context "with hint set to true" do
        before do
          expect(subject).to receive(:definition).and_return({ hint: true })
          expect(Alchemy).to receive(:t).and_return("The hint")
        end

        it "returns the hint from translation" do
          expect(subject.hint).to eq("The hint")
        end
      end
    end
  end
end
