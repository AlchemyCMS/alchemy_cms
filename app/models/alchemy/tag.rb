# frozen_string_literal: true

# == Schema Information
#
# Table name: gutentag_tags
#
#  id             :integer          not null, primary key
#  name           :string
#  taggings_count :integer          default(0)
#

# Just holds some useful tag methods.
# The original Tag model is Gutentag::Tag
module Alchemy
  class Tag < Gutentag::Tag
    # Replaces tag with new tag on all models tagged with tag.
    def self.replace(tag, new_tag)
      tag.taggings.collect(&:taggable).each do |taggable|
        taggable.tag_list.delete(tag.name)
        taggable.tag_list << new_tag.name
        taggable.save
      end
    end
  end
end
