require 'spec_helper'

module Alchemy::Admin
  describe WidgetConfig do

    let(:widget) { WidgetConfig.new("test", key: :value) }

    it "is a subclass of Struct" do
      expect(widget).to be_kind_of(Struct)
    end

    describe ".initialize" do
      it "initiates a new struct with given widget name and options" do
        expect(widget).to eq(Struct.new(:test, key: :value))
      end
    end
  end
end
