class CreateBookings < ActiveRecord::Migration[5.2]
  def change
    create_table :bookings do |t|
      t.date :from
      t.date :until

      t.timestamps
    end
  end
end
