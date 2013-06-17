module Alchemy
  class SiteProperty < ActiveRecord::Base
    attr_accessible :name, :site_id, :property_type, :value
  end
end

