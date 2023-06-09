# frozen_string_literal: true

class Series < ActiveRecord::Base
  extend Alchemy::SearchableResource
end
