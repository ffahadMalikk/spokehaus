class Booking < ActiveRecord::Base

  LATE_CANCELLATION_CUTOFF = 6.hours

  belongs_to :scheduled_class
  belongs_to :user

  validates :bikes, presence: true
  validates :scheduled_class, presence: true
  validates :user, presence: true, unless: :pending_waitlist?

  validates_uniqueness_of :user, scope: :scheduled_class_id, allow_nil: true
  validate :validates_one_bike_reservation_per_class, unless: :pending_waitlist?

  has_many :waitlist_entries

  enum status: [
    :unknown,
    :guest,
    :pending_credits,
    :processing,
    :booked,
    :failed,
    :pending_waitlist
  ]

  def self.pending_statuses
    @_pending_status ||= [
      statuses[:guest],
      statuses[:pending_credits],
      statuses[:pending_waitlist]
    ]
  end

  def self.inactive_statuses
    @_inactive_statuses ||= [
      statuses[:failed],
      statuses[:processing],
    ]
  end

  def self.clear_pending_for(user)
    user.bookings.pending.destroy_all
    user.bookings.failed.where('array_length(bike_ids, 1) = 1').destroy_all
  end

  scope :for, ->(user) { where(user: user) }
  scope :pending, -> { where(status: pending_statuses) }
  scope :upcoming, -> {
    joins(:scheduled_class)
    .where("scheduled_classes.start_time >= ?", Time.zone.now)
  }

  def bikes
    @bikes ||= Bike.where(id: bike_ids)
  end

  def bikes=(bikes)
    @bikes = bikes
    self.bike_ids = @bikes.map(&:id)
  end

  def bike_ids=(ids)
    super(ids)
    @bikes = nil
  end

  def save_pending_registration
    guest! && defer_booking_expiry
  end

  def save_pending_credits
    pending_credits! && defer_booking_expiry
  end

  def pending?
    value = Booking.statuses[self.status]
    Booking.pending_statuses.include?(value)
  end

  def bike_count
    bikes.count
  end

  def cost_in_credits
    bike_count
  end

  def late_cancel?
    (Time.now + LATE_CANCELLATION_CUTOFF) > scheduled_class.start_time
  end

  def can_cancel?
    Time.now < scheduled_class.start_time
  end

  private

  def defer_booking_expiry
    BookingExpiryJob.enqueue(self.id)
    true
  end

  def validates_one_bike_reservation_per_class
    # check for overlapping bike_ids with in the same class
    # bike_ids have pg type integer[] so we use the overlap operator (&&)
    overlapping_bikes = Booking.
      where.not(id: id).
      where(scheduled_class: scheduled_class).
      where("bike_ids && '{?}'", bike_ids)

    if overlapping_bikes.any?
      errors.add(:bikes, 'are double-booked')
    end
  end

end
