class AddFriendCreditsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :friend_credits, :integer, null: false, default: 0
  end
end
