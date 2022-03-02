require 'rails_helper'

RSpec.describe BookingExpiryJob, type: :model do

  scenario "the sender has a credit to give" do
    create(:one_ride_package)
    sender = create(:registered_user, friend_credits: 1)
    recipient = create(:registered_user)

    gift = create(:gift, {
      sender: sender,
      recipient_email: recipient.email
    })

    DeliverGiftJob.new.perform(gift.id)
    sender.reload
    recipient.reload

    user_in_api = FakeMindBodyApi::Application.find_user(recipient.id)
    expect(user_in_api.credits).to eq(1)
  end

end
