class AddConstraintsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :phone_number, 'char(10)', null: true
    change_column :users, :email, :string, default: nil, null: true
    change_column :users, :birthdate, :date, null: false
  end
end
