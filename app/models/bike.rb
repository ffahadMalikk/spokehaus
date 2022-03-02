class Bike < ActiveRecord::Base
  validates :position, presence: true

  enum status: [
    :ok,
    :unavailable
  ]

  def states
    s = [self.status]
    s << 'reserved' if is_reserved?
    s
  end
end
