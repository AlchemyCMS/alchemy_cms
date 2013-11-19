# == Schema Information
#
# Table name: alchemy_essence_selects
#
#  id         :integer          not null, primary key
#  value      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  creator_id :integer
#  updater_id :integer
#

# Provides a select box that stores string values.
module Alchemy
  class EssenceSelect < ActiveRecord::Base
    acts_as_essence ingredient_column: 'value'
  end
end
