# frozen_string_literal: true

require 'spec_helper'

describe 'A User-defined Essence' do
  describe DummyModel do
    it_behaves_like "an essence" do
      let(:essence)          { DummyModel.new }
      let(:ingredient_value) { "Some String" }
    end
  end
end
