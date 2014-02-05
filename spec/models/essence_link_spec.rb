require 'spec_helper'

module Alchemy
  describe EssenceLink do
    it_behaves_like "an essence" do
      let(:essence)          { EssenceLink.new }
      let(:ingredient_value) { 'http://alchemy-cms.com' }
    end
  end
end
