class AddUuidsToUsers < ActiveRecord::Migration

  def change
    remove_column :bookings, :user_id, :integer
    remove_column :users, :id, :primary_key
    add_column :users, :id, :uuid, null: false, default: 'uuid_generate_v4()'
    exec_query 'alter table users add primary key(id);'

    add_column :bookings, :user_id, :uuid, null: false
    add_foreign_key :bookings, :users
  end

end
