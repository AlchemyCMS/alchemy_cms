# frozen_string_literal: true

require 'spec_helper'

module Alchemy
  describe EssenceSelect do
    it_behaves_like "an essence" do
      let(:essence)          { EssenceSelect.new }
      let(:ingredient_value) { 'select value' }
    end
  end
end
