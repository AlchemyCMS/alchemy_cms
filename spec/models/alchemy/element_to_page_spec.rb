# frozen_string_literal: true

require 'spec_helper'

module Alchemy
  describe ElementToPage do
    # ClassMethods

    describe '.table_name' do
      it "should return table name" do
        expect(ElementToPage.table_name).to eq('alchemy_elements_alchemy_pages')
      end
    end
  end
end
