# frozen_string_literal: true

class CreateEssenceAudios < ActiveRecord::Migration[6.0]
  def up
    return if table_exists? :alchemy_essence_audios

    create_table :alchemy_essence_audios do |t|
      t.references :attachment
      t.boolean :controls, default: true, null: false
      t.boolean :autoplay, default: false
      t.boolean :loop, default: false, null: false
      t.boolean :muted, default: false, null: false
    end
  end

  def down
    drop_table :alchemy_essence_audios
  end
end
