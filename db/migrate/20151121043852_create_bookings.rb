class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.references :bike, index: true, foreign_key: true
      t.integer :scheduled_class_id, index: true, null: false

      t.timestamps null: false
    end
  end
end
