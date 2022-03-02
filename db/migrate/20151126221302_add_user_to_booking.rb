class AddUserToBooking < ActiveRecord::Migration
  def change
    add_reference :bookings, :user, index: true, foreign_key: true, null: false
  end
end
