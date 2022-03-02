module Pages
  class Booking < Base

    def initialize(scheduled_class_id)
      @class_id = scheduled_class_id
    end

    def visit_page
      visit self.path
    end

    def has_bikes?(count)
      bikes = all('.bikes-layout-bike')
      bikes.count == count
    end

    def has_notice?(localization_key)
      page.has_content?(I18n.t(localization_key))
    end

    def select_bike(position)
      check position
    end

    def deselect_bike(position)
      uncheck position
    end

    def submit
      click_on I18n.t('bookings.submit')
    end

    def path
      new_scheduled_class_booking_path(@class_id)
    end

  end
end
