# frozen_string_literal: true

class Event < ActiveRecord::Base
  include Alchemy::Taggable

  validates_presence_of :name
  belongs_to :location
  before_destroy :abort_if_name_is_undestructible

  scope :starting_today, -> { where(starts_at: Time.current.at_midnight..Date.tomorrow.at_midnight) }
  scope :future, -> { where("starts_at > ?", Date.tomorrow.at_midnight) }

  def self.alchemy_resource_relations
    {
      location: {attr_method: "name", attr_type: "string"},
    }
  end

  def self.alchemy_resource_filters
    %w(starting_today future)
  end

  private

  def abort_if_name_is_undestructible
    if name == "Undestructible"
      errors.add(:base, "This is the undestructible event!")
      throw(:abort)
    end
  end
end
