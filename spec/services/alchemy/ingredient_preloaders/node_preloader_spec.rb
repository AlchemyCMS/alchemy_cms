# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::IngredientPreloaders::NodePreloader do
  describe ".call" do
    context "with an empty array" do
      it "does not call the AR preloader" do
        expect(ActiveRecord::Associations::Preloader).not_to receive(:new)
        described_class.call([])
      end
    end

    context "with nil" do
      it "does not call the AR preloader" do
        expect(ActiveRecord::Associations::Preloader).not_to receive(:new)
        described_class.call(nil)
      end
    end

    context "with nodes" do
      let(:nodes) { [build(:alchemy_node)] }

      it "preloads the :page and :children associations" do
        preloader = instance_double(ActiveRecord::Associations::Preloader, call: nil)
        expect(ActiveRecord::Associations::Preloader).to receive(:new).with(
          records: nodes,
          associations: [:page, :children]
        ).and_return(preloader)
        described_class.call(nodes)
      end
    end
  end
end
