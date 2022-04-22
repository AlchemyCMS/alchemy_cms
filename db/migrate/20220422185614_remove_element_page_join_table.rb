class RemoveElementPageJoinTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :alchemy_elements_alchemy_pages id: false do |t|
      t.references "element"
      t.references "page"
    end
  end
end
