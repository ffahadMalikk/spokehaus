class User < ActiveRecord::Base
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable

  with_options dependent: :destroy do |user|
    user.has_many :bookings
    user.has_many :waitlist_entries
  end

  enum status: [
    :guest,
    :pending,
    :registered,
  ]

  enum role: [
    :client,
    :admin,
  ]

  validates :name, presence: true

  def self.create_guest
    name = "guest_#{SecureRandom.hex(16)}"
    guest.create!(
      name: name,
      email: "#{name}@spokehaus.ca",
      password: SecureRandom.hex(32)
    )
  end

  def first_name
    fullname.first
  end

  def fullname
    Fullname.new(name)
  end

  def stored_card
    StoredCreditCard.new(cc_last_four, cc_expiry)
  end

  def store_card_info(card)
    update!(cc_last_four: card.last_four, cc_expiry: card.expiry)
  end

  def has_stored_card?
    stored_card.present?
  end

  def has_credits_to_give?
    friend_credits > 0
  end

end
