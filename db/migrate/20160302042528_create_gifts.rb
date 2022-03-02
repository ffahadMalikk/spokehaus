class CreateGifts < ActiveRecord::Migration
  def change
    create_table :gifts, id: :uuid do |t|
      t.string :recipient_email, null: false
      t.uuid :sender_id, null: false, foreign_key: true, index: true
      t.integer :credits, null: false
      t.text :message, default: "", null: false
      t.integer :status, null: false, default: 0

      t.timestamps null: false
    end

  end
end
