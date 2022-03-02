class AddCreditCardInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :cc_last_four, :integer
    add_column :users, :cc_expiry, :datetime
  end
end
