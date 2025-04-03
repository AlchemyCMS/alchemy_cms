# frozen_string_literal: true

class Event < ActiveRecord::Base
  extend Alchemy::SearchableResource
  include Alchemy::Taggable

  validates_presence_of :name
  belongs_to :location

  enum :event_type, {
    expo: 0,
    workshop: 1
  }

  before_destroy :abort_if_name_is_undestructible

  scope :starting_today, -> { where(starts_at: Time.current.at_midnight..Date.tomorrow.at_midnight) }
  scope :future, -> { where("starts_at >= ?", Date.today.at_midnight) }
  scope :by_location_id, ->(id) { where(location_id: id) }
  scope :by_timeframe, ->(timeframe) {
    case timeframe
    when "starting_today" then starting_today
    when "future" then future
    else
      all
    end
  }

  def self.ransackable_attributes(*)
    [
      "name",
      "starts_at"
    ]
  end

  def self.alchemy_resource_relations
    {
      location: {attr_method: "name", attr_type: "string"}
    }
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i[by_location_id by_timeframe]
  end

  # See https://github.com/activerecord-hackery/ransack/issues/1232
  def self.ransackable_scopes_skip_sanitize_args(_auth_object = nil)
    [:by_location_id]
  end

  private

  def abort_if_name_is_undestructible
    if name == "Undestructible"
      errors.add(:base, "This is the undestructible event!")
      throw(:abort)
    end
  end
end
