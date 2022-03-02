class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.integer :price_in_cents, null: false
      t.decimal :tax_rate, null: false
      t.string :name, null: false
      t.integer :count, null: false

      t.timestamps null: false
    end
  end
end
