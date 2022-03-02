class AddShoeSizeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :shoe_size, :decimal
  end
end
