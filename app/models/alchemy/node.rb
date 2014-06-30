module Alchemy
  class Node < ActiveRecord::Base
    stampable stamper_class_name: Alchemy.user_class_name
    belongs_to :navigatable, polymorphic: true, dependent: :nullify

    # Returns the the url value.
    # Either the value is stored in the database, aka. an external url.
    # Or, if attached, the values comes from a navigatable.
    def url
      read_attribute(:url) || navigatable.try(:to_param)
    end
  end
end
