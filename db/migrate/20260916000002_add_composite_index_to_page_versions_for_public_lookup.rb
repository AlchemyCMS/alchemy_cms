class AddCompositeIndexToPageVersionsForPublicLookup < ActiveRecord::Migration[7.2]
  disable_ddl_transaction! if connection.adapter_name.match?(/postgres/i)

  # The public-version lookup filters on page_id then applies the publication-
  # window predicate (public_on / public_until) and orders by public_on DESC
  # LIMIT 1.  The existing indexes on page_id and (public_on, public_until) are
  # separate; Postgres picks the page_id index and then re-evaluates the date
  # conditions as a filter.  A composite index lets the planner satisfy the
  # equality lookup and the range/IS NULL conditions in a single index scan.
  def change
    add_index :alchemy_page_versions,
      [:page_id, :public_on, :public_until],
      name: "idx_alchemy_page_versions_on_page_id_and_publication",
      algorithm: algorithm
  end

  private

  def algorithm
    connection.adapter_name.match?(/postgres/i) ? :concurrently : nil
  end
end
