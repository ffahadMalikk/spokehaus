module Bike::WithReservations

  def self.for(scheduled_class)
    class_id = ActiveRecord::Base.connection.quote(scheduled_class.id)

    Bike \
      .joins("left join bookings on bikes.id = ANY(bookings.bike_ids) and bookings.scheduled_class_id = #{class_id}")
      .order('bikes.position')
      .select("bikes.*, (bookings.scheduled_class_id = #{class_id}) as is_reserved, bookings.user_id")
  end

end
