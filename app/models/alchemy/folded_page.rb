module Alchemy
  class FoldedPage < ActiveRecord::Base
    belongs_to :page
    belongs_to :user, class_name: Alchemy.user_class_name
  end
end
