class AddWaitlistEntries < ActiveRecord::Migration

  def change
    create_table :waitlist_entries, id: :uuid do |t|
      t.uuid :user_id, null: false, foreign_key: true, index: true
      t.integer :scheduled_class_id, null: false, foreign_key: true, index: true
      t.integer :status, default: 0
      t.integer :booking_id
      t.timestamps null: false
    end
  end

end
