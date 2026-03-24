# frozen_string_literal: true

class Location < ActiveRecord::Base
  extend Alchemy::SearchableResource
  include Alchemy::Taggable

  has_many :events

  def self.ransackable_associations(_auth_object = nil)
    [
      :events
    ]
  end
end
