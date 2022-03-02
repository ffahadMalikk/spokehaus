require 'rails_helper'

describe 'Booking a class as a registered user' do

  before { Timecop.freeze(Opening::Day) }
  after  { Timecop.return }

  scenario 'booking a class' do
    # Given that I am signed as a registered user
    user = create(:user, status: :registered)
    login_as(user)

    # And there is a class and bikes
    cls = create(:scheduled_class)
    bikes = create_list(:bike, 3)

    # And there is a package that I can use to buy credits
    package = create(:package, name: '3 Ride', count: 3)

    # When i visit the booking page
    booking_page = Pages::Booking.new(cls.id)
    booking_page.visit_page

    # I should see a page with the bikes
    expect(booking_page).to have_bikes(3)

    # When I choose 2 bikes
    booking_page.select_bike(bikes.first.position)
    booking_page.select_bike(bikes.last.position)
    booking_page.submit

    # And I should see the list of packages
    package_list_page = Pages::PackageList.new
    expect(current_path).to eq package_list_page.path

    # And an alert that my booking is pending credits
    expect(package_list_page).to have_booking_pending_credits

    # When I choose the package
    package_list_page.purchase(package.id)

    # And I fill in my credit card information
    cc = {
      card_number: '1234 5678 9012 3456',
      address: '123 Green St.',
      city: 'Toronto',
      province: 'Ontario',
      postal_code: 'M4L 2V5',
      card_holder: 'Barry Fastminster',
      expiry_year: 2018,
      expiry_month: 6,
    }

    package_list_page.provide_credit_card(cc)
    package_list_page.save_card

    # and click Purchase
    package_list_page.submit_purchase

    # Then I should see my profile
    profile_page = Pages::Profile.new
    expect(current_path).to eq profile_page.path

    # And that I am booked for the class
    expect(profile_page).to have_successful_booking_notice_for(cls)
    expect(profile_page).to have_booked_class(cls)

    # And I should no longer see the pending booking icon
    expect(profile_page).to_not have_booking_pending_credits
  end

end
