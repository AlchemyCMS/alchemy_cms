module Alchemy
  class FoldedPage < ActiveRecord::Base
    belongs_to :page
    belongs_to :user
  end
end
