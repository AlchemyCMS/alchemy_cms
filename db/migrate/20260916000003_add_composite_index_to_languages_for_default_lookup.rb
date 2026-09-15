class AddCompositeIndexToLanguagesForDefaultLookup < ActiveRecord::Migration[7.2]
  disable_ddl_transaction! if connection.adapter_name.match?(/postgres/i)

  # The default-language lookup is `WHERE site_id = ? AND "default" = ? LIMIT 1`.
  # The existing index on site_id alone causes Postgres to fetch every language
  # row for the site and then filter by the "default" boolean.  A composite
  # index on (site_id, default) lets the planner satisfy both conditions in a
  # single index scan and return immediately due to the LIMIT 1.
  def change
    add_index :alchemy_languages,
      [:site_id, :default],
      name: "idx_alchemy_languages_on_site_id_and_default",
      algorithm: algorithm
  end

  private

  def algorithm
    connection.adapter_name.match?(/postgres/i) ? :concurrently : nil
  end
end
