class AddUniqueConstraintsToBookings < ActiveRecord::Migration
  def change
    add_index :bookings, [:scheduled_class_id, :bike_id], unique: true
    add_index :bookings, [:scheduled_class_id, :user_id], unique: true
  end
end
