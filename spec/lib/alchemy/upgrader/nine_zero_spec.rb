# frozen_string_literal: true

require "rails_helper"
require "alchemy/upgrader"

RSpec.describe Alchemy::Upgrader::NineZero do
  let(:upgrader) { Alchemy::Upgrader["9.0"] }

  describe "#remove_deprecated_columns" do
    subject { upgrader.remove_deprecated_columns }

    before do
      allow(upgrader).to receive(:desc)
    end

    context "without deprecated columns" do
      it "does nothing" do
        expect(upgrader).not_to receive(:yes?)
        expect(upgrader).not_to receive(:todo)
        subject
      end
    end

    context "with deprecated columns" do
      before do
        allow(ActiveRecord::Base.connection).to receive(:column_exists?).and_return(false)
        allow(ActiveRecord::Base.connection).to receive(:column_exists?).with(:alchemy_pages, "title").and_return(true)
      end

      context "when confirmed" do
        before { allow(upgrader).to receive(:yes?).and_return(true) }

        it "removes them" do
          expect(Alchemy::Tidy).to receive(:remove_deprecated_columns)
          subject
        end
      end

      context "when declined" do
        before { allow(upgrader).to receive(:yes?).and_return(false) }

        it "keeps them and adds a todo" do
          expect(Alchemy::Tidy).not_to receive(:remove_deprecated_columns)
          expect(upgrader).to receive(:todo).with(/alchemy:tidy:remove_deprecated_columns/, kind_of(String))
          subject
        end
      end
    end
  end
end
