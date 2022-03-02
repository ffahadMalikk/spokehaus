class CreateScheduledClasses < ActiveRecord::Migration
  def change
    create_table :scheduled_classes do |t|
      t.string :class_id, index: true, null: false
      t.string :name, null: false
      t.string :description
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.integer :capacity, null: false, default: 0
      t.integer :booked, null: false, default: 0
      t.integer :waitlisted, null: false, default: 0
      t.boolean :is_available, null: false, default: true
      t.boolean :is_canceled, null: false, default: false
      t.references :staff

      t.timestamps null: false
    end
  end
end
