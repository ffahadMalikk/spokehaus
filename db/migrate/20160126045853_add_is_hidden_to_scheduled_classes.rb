class AddIsHiddenToScheduledClasses < ActiveRecord::Migration
  def change
    add_column :scheduled_classes, :is_hidden, :boolean, null: false, default: false
  end
end
