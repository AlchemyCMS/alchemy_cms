# frozen_string_literal: true

# == Schema Information
#
# Table name: gutentag_tags
#
#  id             :integer          not null, primary key
#  name           :string           not null
#  taggings_count :integer          default(0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_gutentag_tags_on_name            (name) UNIQUE
#  index_gutentag_tags_on_taggings_count  (taggings_count)
#

# Just holds some useful tag methods.
# The original Tag model is Gutentag::Tag
module Alchemy
  class Tag < Gutentag::Tag
    def self.ransackable_attributes(_auth_object = nil)
      %w[created_at id name taggings_count updated_at]
    end

    def self.ransackable_associations(_auth_object = nil)
      %w[taggings]
    end

    # Replaces tag with new tag on all models tagged with tag.
    def self.replace(tag, new_tag)
      tag.taggings.collect(&:taggable).each do |taggable|
        taggable.tag_names = taggable.tag_names - [tag.name] + [new_tag.name]
        taggable.save
      end
    end
  end
end
