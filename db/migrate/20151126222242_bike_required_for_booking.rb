class BikeRequiredForBooking < ActiveRecord::Migration
  def change
    change_column :bookings, :bike_id, :integer, null: false
  end
end
