# frozen_string_literal: true

# This migration comes from alchemy (originally 20220622130905)
class AddPlaysinlineToAlchemyEssenceVideos < ActiveRecord::Migration[6.0]
  def change
    return if column_exists?(:alchemy_essence_videos, :playsinline)

    add_column :alchemy_essence_videos, :playsinline, :boolean, default: false, null: false
  end
end
