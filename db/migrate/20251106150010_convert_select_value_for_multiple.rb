class ConvertSelectValueForMultiple < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
        UPDATE alchemy_ingredients
        SET value = CONCAT('["', value, '"]')
        WHERE type = 'Alchemy::Ingredients::Select';
    SQL
  end
end
