require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe StoreCreditCardJob, type: :worker do

  it 'stores a credit card in the API and the DB' do
    api = instance_double(MindBodyApi)
    expect(MindBodyApi).to receive(:new).and_return(api)

    user = create(:registered_user)
    expiry = Time.zone.local(2020, 6)

    credit_card = CreditCard.new(
      "1234-2345-3465-4567",
      "123 Green St.",
      "Toronto",
      "ON",
      "H0H0H0",
      "User McChargerson",
      expiry.to_date
    )

    Sidekiq::Testing.inline! do
      expect(api).to receive(:store_card).with(client_id: user.id, card: credit_card).and_return(true)
      StoreCreditCardJob.store(credit_card, for_user: user)
      user.reload
      expect(user.stored_card).to eq StoredCreditCard.new(4567, expiry)
    end
  end
end
