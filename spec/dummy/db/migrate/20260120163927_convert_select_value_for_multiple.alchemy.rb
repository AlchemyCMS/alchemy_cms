# This migration comes from alchemy (originally 20251106150010)
class ConvertSelectValueForMultiple < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
        UPDATE alchemy_ingredients
        SET value = CONCAT('["', value, '"]')
        WHERE type = 'Alchemy::Ingredients::Select' AND value NOT LIKE '["%"]' ;
    SQL
  end
end
