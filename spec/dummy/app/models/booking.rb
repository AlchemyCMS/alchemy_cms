# frozen_string_literal: true

class Booking < ActiveRecord::Base
  extend Alchemy::SearchableResource

  scope :starting_today, -> { where(from: Time.current.at_midnight..Date.tomorrow.at_midnight) }
scope :future, -> { where(from: Date.tomorrow.at_midnight..) }
  scope :by_date, ->(date) { where(from: date.to_date.beginning_of_day..date.to_date.end_of_day) }

  def self.alchemy_resource_filters
    [
      {
        name: :by_date,
        values: (Date.today..Date.today + 1.week).map(&:to_s)
      },
      {
        name: :misc,
        values: %i[future starting_today]
      }
    ]
  end
end
