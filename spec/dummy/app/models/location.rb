class Location < ActiveRecord::Base
  has_many :events
end
