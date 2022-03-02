module Pages
  class Base
    include Capybara::DSL
    include Rails.application.routes.url_helpers

    def has_booking_alert?
      booking_alert.present?
    end

    def booking_alert
      all('a[role=alert] .booking-help').first
    end

    def booking_alert_text
      booking_alert.try(:text)
    end

    def sign_out
      visit '/profile'
      click_on 'Sign out'
    end

  end
end
