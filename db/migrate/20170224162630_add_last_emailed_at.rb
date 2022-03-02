class AddLastEmailedAt < ActiveRecord::Migration
  def change
    add_column :waitlist_entries, :emailed_at, :datetime
  end
end
