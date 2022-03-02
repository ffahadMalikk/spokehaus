class AddFriendCreditsToPackages < ActiveRecord::Migration
  def change
    add_column :packages, :friend_credits, :integer, null: false, default: 0
  end
end
