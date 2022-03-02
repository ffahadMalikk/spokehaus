class AddStatusToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :status, :integer, null: false, default: 0
  end
end
