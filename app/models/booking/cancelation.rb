class Booking::Cancelation
  attr_reader :booking, :api

  def initialize(booking, api = nil)
    @booking = booking
    @api = api || MindBodyApi
  end

  def perform
    is_removed_from_class = if booking.booked?
      cancel(booking)
    else
      true
    end

    scheduled_class = booking.scheduled_class
    success = is_removed_from_class && booking.destroy
    WaitlistEntry::Service.new(scheduled_class).notify_waitlisted_users
    return success
  end

  private

  def cancel(booking)
    api.cancel_booking(booking, late_cancel: booking.late_cancel?)
  rescue MindBody::ApiError => e
    Rails.logger.error(e)
    Honeybadger.notify(e)
    false
  end

end
