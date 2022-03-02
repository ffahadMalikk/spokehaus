class Payments::CreditCard < MindBody::Payments::CreditCard

  def initialize(amount, credit_card)
    super(
      amount,
      credit_card.number,
      credit_card.address,
      credit_card.city,
      credit_card.province,
      credit_card.postal_code,
      credit_card.name_on_card,
      credit_card.expiry.month,
      credit_card.expiry.year
    )
  end

end
