class AddStatusToBikes < ActiveRecord::Migration
  def change
    add_column :bikes, :status, :integer, null: false, default: 0
  end
end
