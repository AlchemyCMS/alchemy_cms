class ConvertSelectValueForMultiple < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL
        UPDATE alchemy_ingredients
        SET value = '["' || value || '"]'
        WHERE type = 'Alchemy::Ingredients::Select' AND value NOT LIKE '["%"]';
    SQL
  end
end
