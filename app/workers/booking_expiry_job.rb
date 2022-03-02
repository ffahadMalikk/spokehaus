class BookingExpiryJob
  include Sidekiq::Worker

  def self.enqueue(booking_id)
    perform_in(30.minutes, booking_id)
  end

  def perform(booking_id)
    # TODO consider notifying the user somehow (action_cable?)
    booking = Booking.find(booking_id)
    if booking.pending?
      scheduled_class = booking.scheduled_class
      booking.destroy!
      WaitlistEntry::Service
        .new(scheduled_class)
        .notify_waitlisted_users
    end
  rescue ActiveRecord::RecordNotFound
    # no-op
  end
end
