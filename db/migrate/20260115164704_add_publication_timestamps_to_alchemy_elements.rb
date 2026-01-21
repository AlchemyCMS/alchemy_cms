class AddPublicationTimestampsToAlchemyElements < ActiveRecord::Migration[7.2]
  def up
    add_column :alchemy_elements, :public_on, :datetime
    add_column :alchemy_elements, :public_until, :datetime

    execute <<-SQL
      UPDATE alchemy_elements
      SET public_on = created_at
      WHERE public = #{connection.quoted_true}
    SQL
  end

  def down
    execute <<-SQL
      UPDATE alchemy_elements
      SET public = CASE
        WHEN public_on IS NOT NULL AND public_on <= CURRENT_TIMESTAMP
        THEN #{connection.quoted_true}
        ELSE #{connection.quoted_false}
      END
    SQL

    remove_column :alchemy_elements, :public_until
    remove_column :alchemy_elements, :public_on
  end
end
