class AddHiddenPackage < ActiveRecord::Migration
  def change
    add_column :packages, :is_hidden, :boolean
  end
end
