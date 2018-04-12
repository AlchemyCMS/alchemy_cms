# frozen_string_literal: true

require 'spec_helper'

module Alchemy
  describe 'Paths' do
    describe 'defaults' do
      it 'has default value for Alchemy.admin_path' do
        expect(Alchemy.admin_path).to eq('admin')
      end

      it 'has default value for Alchemy.admin_constraints' do
        expect(Alchemy.admin_constraints).to eq({})
      end
    end
  end
end
