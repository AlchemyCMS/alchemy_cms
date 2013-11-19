# == Schema Information
#
# Table name: tags
#
#  id   :integer          not null, primary key
#  name :string(255)
#

# Just holds some useful tag methods.
# The original Tag model is ActsAsTaggableOn::Tag
module Alchemy
  class Tag < ActsAsTaggableOn::Tag

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
