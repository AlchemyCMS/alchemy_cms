require 'spec_helper'

module Alchemy
  describe EssenceDate do
    let(:essence) { EssenceDate.new }

    it_behaves_like "an essence" do
      let(:essence)          { EssenceDate.new }
      let(:ingredient_value) { DateTime.current.iso8601 }
    end

    describe '#preview_text' do
      context "if no date set" do
        it "should return an empty string" do
          expect(essence.preview_text).to eq("")
        end
      end

      context "if date set" do
        it "should format the date by i18n" do
          essence.date = DateTime.current
          expect(::I18n).to receive(:l).with(essence.date, format: :date)
          essence.preview_text
        end
      end
    end
  end
end
