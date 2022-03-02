require 'rails_helper'
require 'rspec/expectations'

RSpec::Matchers.define :have_available_bikes do |expected|
  match do |actual|
    expect(actual.reject(&:is_reserved)).to match_array(Array.wrap(expected))
  end
end

RSpec.describe Bike::WithReservations, type: :model do

  let(:user)  { create(:user, status: :registered) }

  scenario 'when there are no bookings, it returns all the bikes' do
    cls = create(:scheduled_class)
    bikes = create_list(:bike, 2)

    available = Bike::WithReservations.for(cls)
    expect(available).to have_available_bikes(bikes)
  end

  scenario 'when bike is booked, it is not in the list' do
    cls = create(:scheduled_class)
    bike1, bike2 = create_list(:bike, 2)

    create(:booking, scheduled_class: cls, bikes: [bike1], user: user)

    available = Bike::WithReservations.for(cls)
    expect(available).to have_available_bikes(bike2)
  end

  scenario 'when a bike is booked for a class, it is still available for other classes' do
    bike1, bike2 = create_list(:bike, 2)

    create(:booking,
      scheduled_class: create(:scheduled_class),
      bikes: [bike1],
      user: user)

    cls = create(:scheduled_class)

    available = Bike::WithReservations.for(cls)
    expect(available).to have_available_bikes([bike1, bike2])
  end

  scenario 'when a bike is booked for more than 1 class, it only appears in the list once' do
    # Given a bike
    bike = create(:bike)

    # And two classes
    class1, class2 = 2.times.map { create(:scheduled_class) }

    # When the bike is used for both classes
    create(:booking, bikes: [bike], scheduled_class: class1)
    create(:booking, bikes: [bike], scheduled_class: class2)

    # Then it is only in the list once.
    available = Bike::WithReservations.for(class1)
    expect(available.length).to eq 1
  end

end
