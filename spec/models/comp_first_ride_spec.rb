require 'rails_helper'

RSpec.describe CompFirstRide, type: :model do

  let(:user) { create(:user, status: :guest) }
  let(:api) { instance_double(MindBodyApi, 'api', purchase: nil) }

  before { create(:package, id: 10101, count: 1) }

  it 'completes bookings it has credits for' do
    booking = create(:booking, status: :guest)

    expect(api).to receive(:book_client_to_class)
    expect(api).to receive(:get_remaining_credits).and_return(1)

    CompFirstRide.new(user, booking, api).apply
  end

  it 'does not complete booking it doesnt have credits for' do
    booking = create(:booking, status: :guest, bikes: create_list(:bike, 2))
    expect(api).to_not receive(:book_client_to_class)
    expect(api).to receive(:get_remaining_credits).and_return(1)

    CompFirstRide.new(user, booking, api).apply
  end
end

