# frozen_string_literal: true

class Booking < ActiveRecord::Base
  extend Alchemy::SearchableResource
end
