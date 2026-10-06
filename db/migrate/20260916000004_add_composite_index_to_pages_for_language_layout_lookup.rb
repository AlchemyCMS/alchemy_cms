class AddCompositeIndexToPagesForLanguageLayoutLookup < ActiveRecord::Migration[7.2]
  disable_ddl_transaction! if connection.adapter_name.match?(/postgres/i)

  # The page-lookup query used when resolving a page by URL filters on
  # `language_id = ? AND (layoutpage = ? OR layoutpage IS NULL)` before joining
  # to alchemy_page_versions.  The existing single-column index on language_id
  # covers the equality lookup but Postgres still scans every page in that
  # language and evaluates the layoutpage condition as a row-level filter.  A
  # composite index on (language_id, layoutpage) lets the planner satisfy both
  # conditions up-front, significantly reducing the number of rows that need to
  # be joined against the two page_versions self-joins.
  def change
    add_index :alchemy_pages,
      [:language_id, :layoutpage],
      name: "idx_alchemy_pages_on_language_id_and_layoutpage",
      algorithm: algorithm
  end

  private

  def algorithm
    connection.adapter_name.match?(/postgres/i) ? :concurrently : nil
  end
end
