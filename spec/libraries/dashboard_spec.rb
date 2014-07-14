require 'spec_helper'

module Alchemy::Admin
  describe Dashboard do
    let(:widget) { mock_model('Widget') }

    after do
      # reset @@widgets class variable after each test run
      Dashboard.class_variable_set(:@@widgets, [])
    end

    describe '.register_widget' do
      before { Dashboard.register_widget(widget) }
      it "adds given class to @@widgets" do
        expect(Dashboard.class_variable_get(:@@widgets)).to eq([widget])
      end
    end

    describe '.widgets' do
      context 'when no widget registered yet' do
        it "returns empty array" do
          expect(Dashboard.widgets).to eq([])
        end
      end

      it "returns array containing widgets" do
        Dashboard.register_widget(widget)
        expect(Dashboard.widgets).to eq([widget])
      end
    end
  end
end
