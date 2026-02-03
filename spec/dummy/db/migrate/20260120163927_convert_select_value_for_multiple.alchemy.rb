# This migration comes from alchemy (originally 20251106150010)
class ConvertSelectValueForMultiple < ActiveRecord::Migration[7.1]
  def up
    say_with_time "Converting Alchemy::Ingredients::Select values to multiple" do
      update <<-SQL.squish
        UPDATE alchemy_ingredients
        SET value = '["' || value || '"]'
        WHERE type = 'Alchemy::Ingredients::Select' AND value NOT LIKE '["%"]';
      SQL
    end
  end
end
