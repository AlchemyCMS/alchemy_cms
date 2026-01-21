class CreateBookings < ActiveRecord::Migration[7.2]
  def change
    create_table :bookings do |t|
      t.date :from
      t.date :until

      t.timestamps
    end
  end
end
