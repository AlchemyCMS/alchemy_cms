class Event < ActiveRecord::Base
  validates_presence_of :name
  belongs_to :location

  def self.alchemy_resource_relations
    {
      location: {attr_method: 'name', attr_type: 'string'}
    }
  end
end
