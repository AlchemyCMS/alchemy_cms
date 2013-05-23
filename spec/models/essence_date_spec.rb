require 'spec_helper'

module Alchemy
  describe EssenceDate do
    let(:essence_date) { EssenceDate.new }

    describe '#preview_text' do

      context "if no date set" do
        it "should return an empty string" do
          expect(essence_date.preview_text).to eq("")
        end
      end

      context "if date set" do
        it "should format the date by i18n" do
          essence_date.date = Date.today
          ::I18n.should_receive(:l).with(essence_date.date, format: :date)
          essence_date.preview_text
        end
      end

    end
  end
end
