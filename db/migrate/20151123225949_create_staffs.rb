class CreateStaffs < ActiveRecord::Migration
  def change
    create_table :staffs do |t|
      t.string :name
      t.string :image_url
      t.boolean :is_male
      t.string :bio

      t.timestamps null: false
    end
  end
end
