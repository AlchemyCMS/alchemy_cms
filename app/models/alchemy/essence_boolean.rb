# frozen_string_literal: true

# == Schema Information
#
# Table name: alchemy_essence_booleans
#
#  id         :integer          not null, primary key
#  value      :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  creator_id :integer
#  updater_id :integer
#

# Stores boolean values.
# Provides a checkbox in the editor views.
module Alchemy
  class EssenceBoolean < BaseRecord
    acts_as_essence ingredient_column: 'value'
  end
end
