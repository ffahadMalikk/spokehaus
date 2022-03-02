require 'rails_helper'

RSpec.describe WeeklyCalendarQuery, type: :model do

  before {
    Timecop.travel Time.zone.local(2016, 1, 14, 9, 30)
  }

  after {
    Timecop.return
  }

  let(:user) { create(:user) }
  let(:week) { WeekOf.new(Date.today) }

  it 'marks booked classes' do
    start = Time.zone.local(2016, 1, 14, 12)
    unbooked = create(:scheduled_class,
           name: 'unbooked',
           start_time: start,
           end_time: start + 1.hour)

    start = Time.zone.local(2016, 1, 15)
    booked = create(:scheduled_class,
           name: 'booked',
           start_time: start,
           end_time: start + 1.hour)

    create(:booking, scheduled_class: booked, user: user)
    unbooked, booked = WeeklyCalendarQuery.execute(week, user)
    expect([unbooked, booked].all?(&:present?)).to be true

    expect(unbooked.is_booked?).to be false
    expect(booked.is_booked?).to be true
  end

  it 'requires a user' do
    expect { WeeklyCalendarQuery.execute(week, nil) }.to raise_error 'week and user must be provided'
  end

  it "only shows each class once" do
    # Given a class and 2 bikes, and 2 registered users
    some_class = create(:scheduled_class)
    user1 = create(:registered_user)
    user2 = create(:registered_user)
    bike1 = create(:bike)
    bike2 = create(:bike)

    # When they are booked
    some_class.bookings.create(user: user1, bikes: [bike1])
    some_class.bookings.create(user: user2, bikes: [bike2])

    # Then there is only 1 instance of the class in the schedule
    week = WeekOf.new(some_class.start_date)
    schedule = WeeklyCalendarQuery.execute(week, user1)
    expect(schedule.pluck(:id)).to eq [some_class.id]
  end

end
