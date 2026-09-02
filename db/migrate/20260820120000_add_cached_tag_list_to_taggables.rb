# frozen_string_literal: true

class AddCachedTagListToTaggables < ActiveRecord::Migration[7.2]
  # Only SQLite needs this: it has no real ALTER TABLE, so the remove_column
  # calls in down rebuild the tables via DROP TABLE, whose implicit DELETE
  # cascades into every child row, emptying alchemy_ingredients among others.
  # The adapter's PRAGMA foreign_keys = OFF guard against that is a silent
  # no-op inside a transaction.
  disable_ddl_transaction! if connection.adapter_name.match?(/sqlite/i)

  TAGGABLE_MODELS = %w[
    Alchemy::Element
    Alchemy::Page
    Alchemy::Picture
    Alchemy::Attachment
  ]

  def up
    # Adding nullable columns is a plain ALTER TABLE ADD COLUMN, so up can keep
    # the atomicity the declaration above gives up for both directions.
    connection.transaction do
      TAGGABLE_MODELS.each do |model_name|
        add_column model_name.constantize.table_name, :cached_tag_list, :text, if_not_exists: true
      end

      say_with_time "Backfilling cached_tag_list from existing taggings" do
        backfill
      end
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
