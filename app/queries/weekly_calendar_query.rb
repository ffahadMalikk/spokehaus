module WeeklyCalendarQuery

  def self.execute(week, user)
    raise 'week and user must be provided' if (week.nil? || user.nil?)
    user_id = ActiveRecord::Base.connection.quote(user.id)

    bookings = [
      "left join bookings on bookings.scheduled_class_id = scheduled_classes.id",
      "and (bookings.user_id = #{user_id} or bookings.user_id is null)",
      "and (bookings.status not in (#{Booking.inactive_statuses.join(',')}))",
    ].join(' ')

    ScheduledClass.joins(bookings)
      .visible
      .includes(:staff)
      .between(week.start, week.end)
      .select("scheduled_classes.*, bookings.user_id = #{user_id} as is_booked, bookings.id as user_booking_id")
  end

end
