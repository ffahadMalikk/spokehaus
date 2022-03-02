require 'rails_helper'

RSpec.describe Booking, type: :model do

  it 'requires a bike' do
    booking = build(:booking, bikes: [])

    expect{
      booking.save!(validate: true)
    }.to raise_error(/Bikes can't be blank/)
  end

  it 'requires a class' do
    booking = build(:booking, scheduled_class: nil)

    expect{
      booking.save!(validate: true)
    }.to raise_error(/Scheduled class can't be blank/)

    expect{
      booking.save!(validate: false)
    }.to raise_error(/null value in column "scheduled_class_id" violates not-null constraint/)
  end

  it 'is valid without a user when in pending_waitlist state' do
    booking = build(:booking, user: nil, status: :pending_waitlist)

    booking.save!(validate: true)
    expect(booking).to be_valid

    booking.save!(validate: false)
    expect(booking).to be_valid
  end

  it 'requires a user when not in pending_waitlist state' do
    booking = build(:booking, user: nil, status: :processing)

    expect{
      booking.save!(validate: true)
    }.to raise_error(/User can't be blank/)
  end

  it "allows multiple bookings for the same class" do
    cls = create(:scheduled_class)
    expect {
      2.times { create(:booking, scheduled_class: cls)}
    }.to change {Booking.count}.by(2)
  end

  it "doesn't double book bikes" do
    # Given a previous booking
    existing = create(:booking)

    # And I try to create a new one for the same class and bike
    booking = build(:booking,
      scheduled_class: existing.scheduled_class,
      bikes: [existing.bikes.first]
    )

    # Then errors are raised
    expect{
      booking.save!(validate: true)
    }.to raise_error(/Bikes are double-booked/)

    expect{
      booking.save!(validate: false)
    }.to raise_error(/duplicate key value violates unique constraint "bookings_uniq_bikes_per_class"/)
  end

  it "doesn't double book clients" do
    # Given a previous booking
    existing = create(:booking)

    # And I try to create a new one for the same class and client
    booking = build(:booking,
      scheduled_class: existing.scheduled_class,
      user: existing.user
    )

    # Then errors are raised
    expect{
      booking.save!(validate: true)
    }.to raise_error(/User has already been taken/)
  end

  it "#cost_in_credits" do
    booking = build(:booking, bikes: create_list(:bike, 5))
    expect(booking.cost_in_credits).to eq 5
  end

end

