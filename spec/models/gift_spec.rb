require 'rails_helper'

RSpec.describe Gift, type: :model do

  it 'currently only allows registered users to receive gifts' do
    guest = create(:guest)
    gift = build(:gift, recipient_email: guest.email)
    expect(gift).to_not be_valid
    expect(gift.errors.messages[:recipient_email]).to include('must belong to a registered user')
  end

  it "doesn't allow a user to gift credits to herself" do
    sender = create(:registered_user)
    gift = build(:gift, sender: sender, recipient_email: sender.email)
    expect(gift).to_not be_valid
    expect(gift.errors.messages[:recipient_email]).to include("cannot refer to yourself")
  end

end
