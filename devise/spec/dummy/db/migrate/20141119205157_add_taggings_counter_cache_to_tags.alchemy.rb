# This migration comes from alchemy (originally 20140701160159)
class AddTaggingsCounterCacheToTags < ActiveRecord::Migration[4.2]
  def self.up
    add_column :tags, :taggings_count, :integer, default: 0

    # inserted by Alchemy CMS upgrader
    return unless defined?(ActsAsTaggableOn)

    ActsAsTaggableOn::Tag.reset_column_information
    ActsAsTaggableOn::Tag.find_each do |tag|
      ActsAsTaggableOn::Tag.reset_counters(tag.id, :taggings)
    end
  end

  def self.down
    remove_column :tags, :taggings_count
  end
end
