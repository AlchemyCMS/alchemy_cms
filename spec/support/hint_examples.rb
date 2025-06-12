# frozen_string_literal: true

require "rails_helper"

module Alchemy
  shared_examples_for "having a hint" do
    describe "#hint" do
      before do
        expect(subject).to receive(:definition) do
          if defined?(definition_class)
            definition_class.new(**hint)
          else
            Hash(hint)
          end
        end
      end

      context "with hint as text" do
        let(:hint) { {hint: "The hint"} }

        it "returns the hint" do
          expect(subject.hint).to eq("The hint")
        end
      end

      context "with hint set to true" do
        let(:hint) { {hint: true} }

        before do
          expect(Alchemy).to receive(:t).and_return("The translated hint")
        end

        it "returns the hint from translation" do
          expect(subject.hint).to eq("The translated hint")
        end
      end
    end
  end
end
