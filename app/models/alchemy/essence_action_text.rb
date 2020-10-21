# frozen_string_literal: true

# == Schema Information
#
# Table name: alchemy_essence_richtexts
#
#  id            :integer          not null, primary key
#  content       :text
#  public        :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

module Alchemy
  class EssenceActionText < BaseRecord
    acts_as_essence ingredient_column: :content

    has_rich_text :content
  end
end
