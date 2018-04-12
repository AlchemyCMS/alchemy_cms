# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Resource requests' do
  describe 'csv export' do
    it 'returns valid csv file' do
      get '/admin/events.csv'
      expect(response.content_type).to eq('text/csv')
      expect(response.body).to include(';')
    end

    it 'includes id column' do
      event = create(:event)
      get '/admin/events.csv'
      csv = CSV.parse(response.body, col_sep: ";")
      expect(csv[0][0]).to eq('Id')
      expect(csv[1][0]).to eq(event.id.to_s)
    end

    it 'body does not truncate long text columns' do
      create(:event, description: '*' * 51)
      get '/admin/events.csv'
      csv = CSV.parse(response.body, col_sep: ";")
      expect(csv[1][7]).to_not include('...')
    end
  end
end
