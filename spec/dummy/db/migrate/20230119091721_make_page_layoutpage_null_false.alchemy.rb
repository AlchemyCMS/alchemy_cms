# frozen_string_literal: true
# This migration comes from alchemy (originally 20200514091507)
class MakePageLayoutpageNullFalse < ActiveRecord::Migration[6.0]
  def change
    change_column_null :alchemy_pages, :layoutpage, false, false
  end
end
