class RemapBikes < ActiveRecord::Migration
  def up
    ActiveRecord::Base.transaction do
      Booking.where('created_at > ?', Time.now - 2.months).each do |booking|
        bike_ids = booking.bike_ids
        next if bike_ids.empty?
        mapped = []
        bike_ids.each do |bike_id|
          mapped << (bike_id > 10 ? (bike_id + 5) : bike_id)
        end
        booking.bike_ids = mapped
        booking.save!
      end
    end
  end

  def down
    ActiveRecord::Base.transaction do
      Booking.where('created_at > ?', Time.now - 2.months).each do |booking|
        bike_ids = booking.bike_ids
        next if bike_ids.empty?
        mapped = []
        bike_ids.each do |bike_id|
          mapped << (bike_id > 10 ? (bike_id - 5) : bike_id)
        end
        booking.bike_ids = mapped
        booking.save!
      end
    end
  end
end

