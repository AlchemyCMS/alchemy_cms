class AddPublicationTimestampsToAlchemyElements < ActiveRecord::Migration[7.2]
  def up
    add_column :alchemy_elements, :public_on, :datetime
    add_column :alchemy_elements, :public_until, :datetime

    say_with_time "Populating publication dates" do
      update <<-SQL.squish
        UPDATE alchemy_elements
        SET public_on = created_at
        WHERE public = #{connection.quoted_true}
      SQL
    end
  end

  def down
    say_with_time "Reverting publication dates" do
      update <<-SQL.squish
        UPDATE alchemy_elements
        SET public = CASE
          WHEN public_on IS NOT NULL AND public_on <= CURRENT_TIMESTAMP
          THEN #{connection.quoted_true}
          ELSE #{connection.quoted_false}
        END
      SQL
    end

    remove_column :alchemy_elements, :public_until
    remove_column :alchemy_elements, :public_on
  end
end
