# frozen_string_literal: true

class CreateEssenceVideos < ActiveRecord::Migration[6.0]
  def up
    return if table_exists? :alchemy_essence_videos

    create_table :alchemy_essence_videos do |t|
      t.references :attachment
      t.string :width
      t.string :height
      t.boolean :allow_fullscreen, default: true, null: false
      t.boolean :autoplay, default: false, null: false
      t.boolean :controls, default: true, null: false
      t.boolean :loop, default: false, null: false
      t.boolean :muted, default: false, null: false
      t.string :preload
    end
  end

  def down
    drop_table :alchemy_essence_videos
  end
end
