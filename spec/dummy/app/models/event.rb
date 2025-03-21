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
  scope :future, -> { where("starts_at > ?", Date.tomorrow.at_midnight) }
  scope :by_location_id, ->(id) { where(location_id: id) }

  def self.ransackable_attributes(*)
    [
      "name"
    ]
  end

  def self.alchemy_resource_relations
    {
      location: {attr_method: "name", attr_type: "string"}
    }
  end

  def self.alchemy_resource_filters
    [
      {
        name: :start,
        values: %w[starting_today future]
      },
      {
        name: :by_location_id,
        values: Location.all.map { |l| [l.name, l.id] }
      }
    ]
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
