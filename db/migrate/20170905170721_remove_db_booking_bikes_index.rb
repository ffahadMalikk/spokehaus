class RemoveDbBookingBikesIndex < ActiveRecord::Migration
  def change
    remove_index :bookings, name: 'bookings_uniq_bikes_per_class'
  end
end
