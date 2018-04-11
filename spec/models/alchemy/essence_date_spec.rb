# frozen_string_literal: true

require 'spec_helper'

module Alchemy
  describe EssenceDate do
    let(:essence) { EssenceDate.new }

    it_behaves_like "an essence" do
      let(:essence)          { EssenceDate.new }
      let(:ingredient_value) { Time.current.iso8601 }
    end

    describe '#preview_text' do
      subject { essence.preview_text }

      context "if no date set" do
        it "should return an empty string" do
          is_expected.to eq("")
        end
      end

      context "if date set" do
        it "should format the date by i18n" do
          essence.date = Time.current
          expect(::I18n).to receive(:l).with(essence.date, format: :'alchemy.essence_date')
          subject
        end
      end
    end
  end
end
