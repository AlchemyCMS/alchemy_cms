class ConvertSelectValueForMultiple < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
        UPDATE alchemy_ingredients
        SET value = CONCAT('["', value, '"]')
        WHERE type = 'Alchemy::Ingredients::Select';
    SQL
  end
end
