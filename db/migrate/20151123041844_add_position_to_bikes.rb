class AddPositionToBikes < ActiveRecord::Migration
  def change
    add_column :bikes, :position, :integer, unique: true
  end
end
