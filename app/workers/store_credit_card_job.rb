class StoreCreditCardJob
  include Sidekiq::Worker

  def self.store(credit_card, for_user:)
    expiry = credit_card.expiry
    perform_async(
      for_user.id,
      expiry.year,
      expiry.month,
      credit_card.values
    )
  end

  def perform(user_id, expiry_year, expiry_month, credit_card_values)
    user = User.find(user_id)
    api = MindBodyApi.new

    credit_card = CreditCard.new(*credit_card_values)
    credit_card.expiry = Date.new(expiry_year, expiry_month)

    if api.store_card(client_id: user.id, card: credit_card)
      user.store_card_info(credit_card)
    end
  end

end
