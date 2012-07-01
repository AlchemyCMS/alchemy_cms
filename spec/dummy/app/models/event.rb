class Event < ActiveRecord::Base
  attr_accessible :name, :hidden_name, :starts_at, :ends_at, :description, :published, :entrance_fee, :location_id, :organizer_id
  validates_presence_of :name

end