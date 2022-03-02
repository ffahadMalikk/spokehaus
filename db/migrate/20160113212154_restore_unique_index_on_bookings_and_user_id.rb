class RestoreUniqueIndexOnBookingsAndUserId < ActiveRecord::Migration
  def change
    add_index :bookings, [:scheduled_class_id, :user_id], unique: true
  end
end
