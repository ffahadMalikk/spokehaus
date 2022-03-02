require 'rails_helper'

describe 'Completing pending bookings via the link' do

  scenario 'A booking pending registration' do
    # Given I am a guest user
    visit home_path

    # And I have a guest booking
    user = User.last
    booking = create(:booking, user: user, status: :guest)

    # When I refresh the page
    visit home_path

    # I should see the pending booking button
    pending_booking_button = find('a[role=alert]')

    # When I click it
    pending_booking_button.click

    # Then I should be taken to registration page
    expect(page).to have_content(I18n.t('booking_pending_registration'))
    expect(current_path).to eq new_user_registration_path

    # Then my booking should still be pending
    expect(booking.reload).to be_guest
  end

  scenario 'A booking pending credits' do
    # Given I am a registered user
    user = create(:registered_user)
    login_as user

    # And I have a booking pending credits
    booking = create(:booking, user: user, status: :pending_credits)

    # When I visit the home page
    visit home_path

    # I should see the pending booking button
    pending_booking_button = find('a[role=alert]')

    # When I click it
    pending_booking_button.click

    # Then I should be taken to the buy credits page
    expect(page).to have_content(I18n.t('insufficient_credits'))
    expect(current_path).to eq packages_path

    # Then my booking should still be pending
    expect(booking.reload).to be_pending_credits
  end

  scenario 'completing bookings on sign-in' do
    # Given a class and a bike
    cls = create(:scheduled_class)
    bike = create(:bike)

    # And that I am a registered user with a credit
    user = create(:registered_user, email: 'foo@foo.org', password: 'Supersecret')
    FakeMindBodyApi::Application.find_user(user.id).credits = 1

    # When I book a class anonymously
    calendar_page = Pages::Calendar.new
    calendar_page.visit_page
    booking_page = calendar_page.select_class(cls)
    booking_page.select_bike(bike.position)
    booking_page.submit

    # And then sign in as on my registered account
    sign_in_page = Pages::SignIn.new
    sign_in_page.visit_page
    sign_in_page.sign_in(email: user.email, password: 'Supersecret')

    # I should see the class booked
    calendar_page.visit_page
    expect(calendar_page).to_not have_booking_alert
    expect(calendar_page).to have_booked_class(cls)

    api_user = FakeMindBodyApi::Application.find_user(user.id)
    if Flags.comp_first_ride?
      expect(api_user.credits).to eq 1
    else
      expect(api_user.credits).to eq 0
    end
  end

end
