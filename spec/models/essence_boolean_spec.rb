require 'spec_helper'

module Alchemy
  describe EssenceBoolean, :type => :model do
    it_behaves_like "an essence" do
      let(:essence)          { EssenceBoolean.new }
      let(:ingredient_value) { true }
    end
  end
end
