class RemoveBirthdateConstraint < ActiveRecord::Migration
  def change
    change_column :users, :birthdate, :date, null: true
  end
end
