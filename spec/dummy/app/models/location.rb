# frozen_string_literal: true

class Location < ActiveRecord::Base
  extend Alchemy::SearchableResource
  include Alchemy::Taggable
  has_many :events
end
