class AddCompositeIndexToElementsForPublicVersionLookup < ActiveRecord::Migration[7.2]
  disable_ddl_transaction! if connection.adapter_name.match?(/postgres/i)

  # The public-element query filters on page_version_id first, then applies the
  # publication-window predicate (public_on / public_until), and orders by
  # position.  The existing separate indexes on (page_version_id, position) and
  # (public_on, public_until) force Postgres to pick one and re-check the other
  # as a filter.  A single covering index lets it satisfy all three conditions
  # in one scan.
  def change
    add_index :alchemy_elements,
      [:page_version_id, :public_on, :public_until, :position],
      name: "idx_alchemy_elements_on_version_publication_position",
      algorithm: algorithm
  end

  private

  def algorithm
    connection.adapter_name.match?(/postgres/i) ? :concurrently : nil
  end
end
