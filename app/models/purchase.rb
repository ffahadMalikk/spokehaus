class Purchase
  include Virtus.model
  include ActiveModel::Model

  attr_reader :user, :api

  attribute :payment_type, String, default: :default_payment_type
  attribute :stored_card, StoredCreditCard
  attribute :package_id, Integer

  attribute :name_on_card, String
  attribute :card_number, String
  attribute :address, String
  attribute :city, String
  attribute :province, String
  attribute :postal_code, String
  attribute :expiry_month, Integer, default: 0
  attribute :expiry_year, Integer, default: 0
  attribute :save_card, Boolean

  validates :package_id, presence: true
  validates :payment_type, presence: true,
            inclusion: {in: %w(new_card stored_card)}
  validate :validate_package

  with_options if: :new_card? do |c|
    c.validates :name_on_card, presence: true, length: {minimum: 2, maximum: 32}
    c.validates :card_number, presence: true, length: {minimum: 16, maximum: 19}
    c.validates :address, presence: true, length: {minimum: 2, maximum: 32}
    c.validates :city, presence: true, length: {minimum: 2, maximum: 32}
    c.validates :province, presence: true, length: {minimum: 2, maximum: 32}
    c.validates :postal_code, presence: true, length: {minimum: 5, maximum: 7}
    c.validates :expiry_year, presence: true, numericality: {only_integer: true}
    c.validates :expiry_month, presence: true, numericality: {only_integer: true}
    c.validate :validate_credit_card_expiry
  end

  def save_card
    if super.nil? && new_card?
      true
    else
      super
    end
  end

  def expiry
    Date.new(expiry_year, expiry_month, 1)
  rescue ArgumentError => e
    Rails.logger.error(e)
    nil
  end

  def credit_card
    CreditCard.new(
      card_number,
      address,
      city,
      province,
      postal_code,
      name_on_card,
      expiry
    )
  end

  def should_save_card?
    save_card? && new_card? && credit_card.valid?
  end

  def new_card?
    self.payment_type == 'new_card'
  end

  def stored_card?
    self.payment_type == 'stored_card'
  end

  def package
    @package ||= Package.find_by(id: package_id)
  end

  private

  def default_payment_type
    if stored_card.present?
      'stored_card'
    else
      'new_card'
    end
  end

  def validate_credit_card_expiry
    if expiry.nil?
      errors.add(:expiry_year, 'Invalid expiry date')
      errors.add(:expiry_month, 'Invalid expiry date')
    else
      if expiry_year < Date.today.year
        errors.add(:expiry_year, "Can't be in the past")
      end
      if expiry_month < 1 || expiry_month > 12
        errors.add(:expiry_month, 'Not a valid month')
      end
      if expiry <= Date.today
        errors.add(:expiry_year, 'Expired')
        errors.add(:expiry_month, 'Expired')
      end
    end
  end

  def validate_package
    if package.nil?
      errors.add(:package_id, "is invalid")
    end
  end

end
