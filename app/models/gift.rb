class Gift < ActiveRecord::Base
  belongs_to :sender, class_name: 'User'

  validates :recipient_email, presence: true
  validate :recipient_is_registered
  validate :cant_give_yourself_credits

  enum status: [
    :unsent,
    :delivered,
  ]

  def deliver
    GiftDelivery.new(self).deliver
  end

  private

  def recipient_is_registered
    recipient = User.find_by(email: recipient_email)
    if recipient.nil? || !recipient.registered?
      errors.add(:recipient_email, "must belong to a registered user")
    end
  end

  def cant_give_yourself_credits
    if sender.email == recipient_email
      errors.add(:recipient_email, "cannot refer to yourself")
    end
  end

end
