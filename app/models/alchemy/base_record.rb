# frozen_string_literal: true
module Alchemy
  def self.table_name_prefix
    "alchemy_"
  end

  class BaseRecord < ActiveRecord::Base
    extend Alchemy::SearchableResource

    self.abstract_class = true
  end
end
