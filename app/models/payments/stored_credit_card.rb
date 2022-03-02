class Payments::StoredCreditCard < MindBody::Payments::StoredCreditCard
  attr_reader :expiry_date

  def initialize(amount, stored_card)
    super(amount, stored_card.last_four)
    @expiry_date = stored_card.expiry
  end

  def expired?
    expiry_date.nil? || Date.today >= expiry_date
  end

  def present?
    last_four.present? && expiry_date.present?
  end

  def number
    "xxxx-xxxx-xxxx-#{last_four}"
  end

  def expiry
    return 'xxxx' if expiry_date.nil?

    I18n.l(expiry_date, format: :cc)
  end

end
