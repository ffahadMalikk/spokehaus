require 'rails_helper'

RSpec.describe BookingExpiryJob, type: :model do

  it 'cleans up old guest registrations' do
    booking = create(:booking, status: :guest)

    expect {
      BookingExpiryJob.new.perform(booking.id)
      booking.reload
    }.to raise_error ActiveRecord::RecordNotFound
  end

  it 'cleans up registrations pending credits' do
    booking = create(:booking, status: :pending_credits)

    expect {
      BookingExpiryJob.new.perform(booking.id)
      booking.reload
    }.to raise_error ActiveRecord::RecordNotFound
  end

  it "won't clean up other registrations" do
    booking = create(:booking, status: :booked)

    expect {
      BookingExpiryJob.new.perform(booking.id)
    }.to_not change{
      booking.reload
    }
  end

  it 'handles non-existant bookings' do
    expect {
      BookingExpiryJob.new.perform(-1)
    }.to_not raise_error
  end

end
