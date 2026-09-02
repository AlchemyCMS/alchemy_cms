class AddPublicationTimestampsToAlchemyElements < ActiveRecord::Migration[7.2]
  # Only SQLite needs this: it has no real ALTER TABLE, so the remove_column
  # calls in down rebuild the table via DROP TABLE, whose implicit DELETE
  # cascades into alchemy_ingredients. The adapter's PRAGMA foreign_keys = OFF
  # guard against that is a silent no-op inside a transaction.
  disable_ddl_transaction! if connection.adapter_name.match?(/sqlite/i)

  def up
    # Adding nullable columns is a plain ALTER TABLE ADD COLUMN, so up can keep
    # the atomicity the declaration above gives up for both directions.
    connection.transaction do
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
  end

  def down
    # Running without a transaction on SQLite, a re-run can start after the
    # columns are already gone, leaving the statement below nothing to read.
    if connection.column_exists?(:alchemy_elements, :public_on)
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
    end

    remove_column :alchemy_elements, :public_until, if_exists: true
    remove_column :alchemy_elements, :public_on, if_exists: true
  end
end
