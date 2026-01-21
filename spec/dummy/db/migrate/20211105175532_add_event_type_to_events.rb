# frozen_string_literal: true

class AddEventTypeToEvents < ActiveRecord::Migration[7.2]
  def change
    add_column :events, :event_type, :integer, null: false, default: 0
  end
end
