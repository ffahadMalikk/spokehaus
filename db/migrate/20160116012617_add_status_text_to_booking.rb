class AddStatusTextToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :status_text, :string
  end
end
