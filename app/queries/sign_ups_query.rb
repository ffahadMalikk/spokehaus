class SignUpsQuery
  attr_reader :scheduled_class

  def initialize(class_id)
    @scheduled_class = ScheduledClass.find(class_id)
  end

  def run
    @scheduled_class.
      bookings.
      booked.
      joins(:user).
      joins("inner join bikes on bikes.id = ANY(bookings.bike_ids)").
      select("bookings.*, bikes.position as bike_position").
      order('bikes.position')
  end

end
