class WaitlistEntry::Service

  attr_reader :scheduled_class

  DEFAULT_EMAIL_PERIOD = 3600.seconds

  def initialize(scheduled_class)
    @scheduled_class = scheduled_class
  end

  # This class method is intended to be used via Sidekiq's
  # delay_for functionality which will cause the emails to go down
  # the line of users on the waitlist
  def self.notify_waitlisted_users(scheduled_class_id)
    scheduled_class = ScheduledClass.find(scheduled_class_id)
    WaitlistEntry::Service.new(scheduled_class).notify_waitlisted_users
  end

  def notify_waitlisted_users
    if scheduled_class.waitlist_entries.queued.empty?
      # Nobody responded to the waitlist emails so mark the
      # spot as open to the public
      ActiveRecord::Base.transaction do
        scheduled_class.waitlist_entries.destroy_all
        scheduled_class.bookings.pending_waitlist.destroy_all
      end
    else
      waitlist_reserved_bookings = []
      available_bikes.each do |bike|
        waitlist_entry = next_in_queue
        break if waitlist_entry.blank?
        ActiveRecord::Base.transaction do
          booking = scheduled_class
            .bookings
            .pending_waitlist
            .where("'{?}' = bike_ids", bike.id)
            .first_or_create!(
              status: :pending_waitlist,
              bike_ids: [bike.id]
            )
          waitlist_entry.update_attributes!(booking: booking)
          waitlist_reserved_bookings << booking
          email_waitlisted_user(waitlist_entry)
        end
      end
      waitlist_reserved_bookings
    end
  end

  def available_bikes
    waitlist_bikes = scheduled_class
      .bookings
      .pending_waitlist
      .pluck(:bike_ids)
      .flatten
    Bike::WithReservations
      .for(scheduled_class)
      .select { |b|
        b.ok? && (!b.is_reserved? || waitlist_bikes.include?(b.id))
      }
  end

  def email_waitlisted_user(waitlist_entry, next_email_attempt_delay=nil)
    WaitlistMailer.delay.notify(waitlist_entry.id)
    waitlist_entry.update_attribute(:emailed_at, Time.now)
    waitlist_entry.emailed!
    schedule_next_email_attempt(next_email_attempt_delay)
  end

  # Remove the email next job.
  # Mark the waitlist entry as accepted and finalize the booking.
  def accept(waitlist_entry)
    booking = waitlist_entry.booking
    return false unless booking.pending_waitlist?
    ActiveRecord::Base.transaction do
      booking.user = waitlist_entry.user
      waitlist_entry.destroy!
      booking.save!
      booking.booked!
    end
  end

  # Remove the scheduled email job.
  # Immediately email the next person on the list.
  # Remove the user from the waitlist
  def decline(waitlist_entry)
    booking = waitlist_entry.booking
    waitlist_entry.destroy
    if (next_entry = next_in_queue).present?
      next_entry.update_attributes(booking: booking)
      email_waitlisted_user(next_entry, 0)
    elsif booking.waitlist_entries.empty?
      booking.destroy
    end
  end

  def schedule_next_email_attempt(delay=nil)
    delay = email_period if delay.nil?
    self
      .class
      .delay_for(delay.seconds)
      .notify_waitlisted_users(scheduled_class.id)
  end

  def email_period
    num_waiting = scheduled_class.waitlist_entries.queued.count
    num_waiting = 1 if num_waiting == 0 # Don't divide by zero
    total_period = (scheduled_class.start_time - 2.hours) - Time.now
    period_per_email = (total_period / num_waiting).to_i
    period = if period_per_email < DEFAULT_EMAIL_PERIOD
      period_per_email
    else
      DEFAULT_EMAIL_PERIOD
    end
    period + rand(60)
  end

  def next_in_queue
    scheduled_class
      .waitlist_entries
      .queued
      .where(booking_id: nil)
      .order('created_at ASC')
      .first
  end

end

