# frozen_string_literal: true
class MakePageLayoutpageNullFalse < ActiveRecord::Migration[5.2]
  def change
    change_column_null :alchemy_pages, :layoutpage, false, false
  end
end
