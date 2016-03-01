module Alchemy
  class PageVersion < ActiveRecord::Base
    belongs_to :page,
      class_name: 'Alchemy::Page',
      inverse_of: :versions,
      required: true
  end
end
