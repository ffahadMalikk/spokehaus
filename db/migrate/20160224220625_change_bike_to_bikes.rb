class ChangeBikeToBikes < ActiveRecord::Migration
  def up
    add_column :bookings, :bike_ids, :integer, array: true, reference: true, foreign_key: true, null: false, default: []

    # StackOverflow special!
    # http://stackoverflow.com/a/8449165/241792
    exec_query <<-SQL
      create or replace function sort_array(integer[]) returns integer[] as $$
        select array_agg(n) from (select n from unnest($1) as t(n) order by n) as a;
      $$ language sql immutable;
    SQL

    exec_query <<-SQL
      create unique index bookings_uniq_bikes_per_class on bookings (scheduled_class_id, sort_array(bike_ids));
    SQL

    exec_query <<-SQL
      update bookings set bike_ids = ('{' || bike_id || '}') ::int[];
    SQL

    remove_column :bookings, :bike_id, :integer
  end

  def down
    add_column :bookings, :bike_id, :integer, reference: true, foreign_key: true
    remove_column :bookings, :bike_ids, :integer, array: true, reference: true, foreign_key: true, null: false, default: []
  end
end
