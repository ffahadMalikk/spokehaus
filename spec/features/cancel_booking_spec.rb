require 'rails_helper'

describe "Cancelling bookings" do

  let!(:api) {
    instance_double(MindBodyApi,
      get_remaining_credits: 0,
      get_client_schedule: [])
  }

  before { allow(MindBodyApi).to receive(:new).and_return(api) }

  scenario "A registered user wants to cancel an existing booking" do
    user = create(:registered_user)
    login_as(user)

    booking = create(:booking, user: user)

    visit edit_booking_path(booking)

    expect(api).to receive(:cancel_booking).with(booking, late_cancel: booking.late_cancel?).and_return(true)
    click_on 'Cancel booking'

    expect(current_path).to eq user_profile_path
    expect(page).to have_content(I18n.t('booking_canceled'))
  end

  scenario "A registered user wants to cancel an existing booking, but it fails" do
    user = create(:registered_user)
    login_as(user)

    booking = create(:booking, user: user)

    visit edit_booking_path(booking)

    expect(api).to receive(:cancel_booking).with(booking, late_cancel: booking.late_cancel?).and_return(false)
    click_on 'Cancel booking'

    expect(current_path).to eq edit_booking_path(booking)
    expect(page).to have_content(I18n.t('booking_not_canceled'))
  end

end
