# frozen_string_literal: true

# This migration comes from alchemy (originally 20260820120000)
class AddCachedTagListToTaggables < ActiveRecord::Migration[7.2]
  TAGGABLE_MODELS = %w[
    Alchemy::Element
    Alchemy::Page
    Alchemy::Picture
    Alchemy::Attachment
  ]

  def up
    TAGGABLE_MODELS.each do |model_name|
      add_column model_name.constantize.table_name, :cached_tag_list, :text,
        default: "[]", null: false, if_not_exists: true
    end

    say_with_time "Backfilling cached_tag_list from existing taggings" do
      backfill
    end
  end

  def down
    TAGGABLE_MODELS.each do |model_name|
      remove_column model_name.constantize.table_name, :cached_tag_list, if_exists: true
    end
  end

  private

  def backfill
    TAGGABLE_MODELS.each do |model_name|
      table = model_name.constantize.table_name
      # Throwaway model so writing the raw JSON bypasses the real model's
      # serializer and picks up the freshly added column without touching it.
      klass = Class.new(ActiveRecord::Base) { self.table_name = table }

      Gutentag::Tagging
        .where(taggable_type: model_name)
        .joins(:tag)
        .pluck(:taggable_id, "gutentag_tags.name")
        .group_by(&:first)
        .each do |taggable_id, rows|
          klass.where(id: taggable_id).update_all(cached_tag_list: rows.map(&:last).uniq.to_json)
        end
    end
  end
end
