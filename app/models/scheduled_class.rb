class ScheduledClass < ActiveRecord::Base
  cattr_accessor :api_class

  validates :id, presence: true
  validates :class_id, presence: true
  validates :name, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :staff, presence: true

  belongs_to :staff

  with_options dependent: :destroy do |scheduled_class|
    scheduled_class.has_many :bookings
    scheduled_class.has_many :waitlist_entries
  end

  scope :between, ->(a, b) {
    where("start_time >= ? and end_time <= ?", a, b).
    order(:start_time)
  }

  scope :visible, -> { where('is_canceled = ? or is_hidden = ?', false, false) }

  def available?
    is_available
  end

  def canceled?
    is_canceled
  end

  def start_date
    start_time.to_date
  end

  def duration
    (end_time.to_time - start_time.to_time).to_i
  end

  def locked?
    start_time < Time.zone.now
  end

  def instructor_name
    staff.name
  end

  def bikes_booked
    bookings.pluck(:bike_ids).flatten.compact.uniq
  end

  def at_capacity?
    bikes_booked.count >= capacity
  end

  def states
    states = []
    states << :cancelled if canceled?
    states << :booked if is_booked?
    states << :locked if locked?
    states
  end

  def self.parse_all(response)
    response.map(&method(:parse))
  end

  def self.parse(record)
    new(convert_attributes(record))
  end

  def self.convert_attributes(record)
    staff_node = record[:staff]
    description = record[:class_description]

    tz_hack = TimeZoneHack.new

    {
      id: record[:id],
      class_id: description[:id],
      name: description[:name],
      description: description[:description],
      start_time: tz_hack.convert_mindbody_time_to_local(record[:start_date_time]),
      end_time: tz_hack.convert_mindbody_time_to_local(record[:end_date_time]),
      capacity: record[:max_capacity],
      booked: record[:total_booked],
      waitlisted: record[:total_booked_waitlist],
      # TODO it is not ideal to repeat the default value here
      # not sure why the database can't handle it
      is_available: record.fetch(:is_available, true),
      is_canceled: record.fetch(:is_canceled, false),
      is_hidden: record.fetch(:hide_cancel, false),
      staff_id: staff_node[:id]
    }
  end

end
