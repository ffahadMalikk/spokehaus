module Pages
  class Calendar < Base

    def visit_page
      visit path
    end

    def path
      calendar_path
    end

    def has_booked_class?(scheduled_class)
      page.has_css?('.booking-calendar-class.booked')
    end

    def select_class(scheduled_class)
      path = new_scheduled_class_booking_path(scheduled_class.id)
      find(:css, "a[href='#{path}']").click
      Pages::Booking.new(scheduled_class.id)
    end

    def bookings_count
      all(".booked").count
    end

  end
end
