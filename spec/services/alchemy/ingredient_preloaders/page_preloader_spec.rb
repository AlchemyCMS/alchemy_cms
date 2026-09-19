# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::IngredientPreloaders::PagePreloader do
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

    context "with pages" do
      let(:pages) { [build(:alchemy_page)] }

      it "preloads the :language association" do
        preloader = instance_double(ActiveRecord::Associations::Preloader, call: nil)
        expect(ActiveRecord::Associations::Preloader).to receive(:new).with(
          records: pages,
          associations: :language
        ).and_return(preloader)
        described_class.call(pages)
      end
    end
  end
end
