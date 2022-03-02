require 'rails_helper'

RSpec.describe "editing bookings" do

  it "allows a user to change their boooking" do
    # Given I am logged in as a registered user with 3 credits
    user = create(:registered_user)
    FakeMindBodyApi::Application.find_user(user.id).credits = 3
    login_as(user)

    # And there are three bikes and a package
    bikes = create_list(:bike, 3)
    cls = create(:scheduled_class)

    booking_page = Pages::Booking.new(cls.id)
    booking_page.visit_page
    booking_page.select_bike(bikes.first.position)
    booking_page.select_bike(bikes.last.position)
    booking_page.submit

    booking = user.bookings.last
    visit edit_booking_path(booking)

    api_user = FakeMindBodyApi::Application.find_user(user.id)
    bookings = FakeMindBodyApi::Application.bookings_for_user(user.id)

    expect(api_user.credits).to eq 1
    expect(bookings.count).to eq 2

    booking_page.deselect_bike(bikes.last.position)
    booking_page.submit

    expect(api_user.credits).to eq(2)
    bookings = FakeMindBodyApi::Application.bookings_for_user(user.id)
    expect(bookings.count).to eq(1)
  end

  private


end
