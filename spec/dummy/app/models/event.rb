# frozen_string_literal: true

class Event < ActiveRecord::Base
  include Alchemy::Taggable

  validates_presence_of :name
  belongs_to :location

  scope :starting_today, -> { where(starts_at: Time.current.at_midnight..Date.tomorrow.at_midnight) }
  scope :future, -> { where("starts_at > ?", Date.tomorrow.at_midnight) }

  def self.alchemy_resource_relations
    {
      location: {attr_method: 'name', attr_type: 'string'}
    }
  end

  def self.alchemy_resource_filters
    %w(starting_today future)
  end
end
