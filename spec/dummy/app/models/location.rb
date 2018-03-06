class Location < ActiveRecord::Base
  include Alchemy::Taggable
  has_many :events
end
