require 'rails_helper'

describe 'A new user books a class and registers.' do

  NOW = Opening::Day + 9.hours + 30.minutes

  before  { Timecop.freeze(NOW) }
  after   { Timecop.return }

  scenario 'With valid registration details' do
    # Given that there is a class at 9:30am with a bike availble
    create(:one_ride_package)
    package = create(:package, count: 3)
    spinning_class = create_class
    bike = create(:bike, position: 5)

    # When click Book a class from the home page
    visit home_path
    within('.cta') { click_on 'Book a Class' }

    # I should see then calendar
    calendar_page = Pages::Calendar.new
    expect(current_path).to eq(calendar_page.path)

    # Then when I select the class and a bike
    booking_page = calendar_page.select_class(spinning_class)
    expect(current_path).to eq(booking_page.path)
    booking_page.select_bike(5)
    booking_page.submit

    # I should see the registration page
    registration_page = Pages::Registration.new
    expect(current_path).to eq(registration_page.path)

    # And I should see that my class is booked pending registration
    expect(registration_page).to have_booking_pending_registration

    # When I enter my details
    registration_page.register(
      name: 'Super Amazing User',
      email: 'super+amazing@user.ca',
      password: 'Supersecret',
      birthdate: '1976-09-06',
      shoe_size:  '10.5'
    )

    if Flags.comp_first_ride?
      first_ride_is_free
    else
      no_free_ride(bike, package, spinning_class)
    end
  end

  def first_ride_is_free
    # I should see the calendar with no pending registration icon
    calendar_page = Pages::Calendar.new
    expect(current_path).to eq calendar_page.path

    # And I should be booked
    expect(calendar_page.bookings_count).to eq(1)
  end

  def no_free_ride(bike, package, spinning_class)
    # Then I should be on the package list page
    package_list_page = Pages::PackageList.new
    expect(current_path).to eq package_list_page.path

    # And I should see that my booking is pending credits
    expect(package_list_page).to have_booking_pending_credits

    # When I select a package
    package_list_page.purchase(package.id)

    # And enter my credit card info
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

    # I should see my profile page
    profile_page = Pages::Profile.new
    expect(current_path).to eq profile_page.path
    expect(profile_page).to_not have_booking_pending

    # And that I'm booked for the class
    expect(page).to have_successful_booking_notice_for(spinning_class)

    user = User.find_by(email: 'super+amazing@user.ca')
    booking = user.bookings.last

    expect(booking).to_not be_nil
    expect(booking.scheduled_class).to eq spinning_class
    expect(booking.bikes).to eq [bike]

    # And that I have 2 remaining credits
    api = MindBodyApi.new
    expect(api.get_remaining_credits(user.id)).to eq 2
  end

  def create_class
    create(:scheduled_class, start_time: NOW, end_time: NOW + 45.minutes)
  end

end
