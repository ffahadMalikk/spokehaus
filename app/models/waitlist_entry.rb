class WaitlistEntry < ActiveRecord::Base

  enum status: [
    :queued,
    :emailed
  ]

  belongs_to :scheduled_class
  belongs_to :user
  belongs_to :booking

  validates_presence_of :scheduled_class
  validates_presence_of :user
  validates_presence_of :booking, if: :emailed?
  validates_uniqueness_of :user, scope: :scheduled_class
  validate :user_not_already_booked

  scope :active, -> {
    joins(:scheduled_class).where('scheduled_classes.start_time > ?', Time.now)
  }

  def self.add(user, scheduled_class)
    scheduled_class.waitlist_entries.where(user: user).first_or_create!
  end

  def self.remove(user, scheduled_class)
    users_entry = scheduled_class.waitlist_entries.find_by(user: user)
    if users_entry.present?
      booking = users_entry.booking
      users_entry.destroy!
      booking.destroy! if booking.present? && booking.waitlist_entries.empty?
    end
    true
  end

  def was_emailed?
    emailed_at.present?
  end

  private

  def user_not_already_booked
    if scheduled_class.bookings.find_by(user: user).present?
      errors[:user] << "is already taken"
    end
  end

end
