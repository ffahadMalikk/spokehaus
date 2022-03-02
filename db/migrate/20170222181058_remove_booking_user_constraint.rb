class RemoveBookingUserConstraint < ActiveRecord::Migration
  def up
    # Allow the user column to be null
    change_column_null(:bookings, :user_id, true)

    # Remove unique index, add a non-unique one
    remove_index :bookings, name: :index_bookings_on_scheduled_class_id_and_user_id
    add_index :bookings, [:scheduled_class_id, :user_id], unique: false
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
