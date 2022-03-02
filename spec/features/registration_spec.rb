require 'rails_helper'

describe 'Registering as a new user' do

  scenario 'With valid registration details' do
    visit home_path
    click_on 'Register'

    if Flags.comp_first_ride?
      package = create(:one_ride_package)
    end

    registration_page = Pages::Registration.new
    registration_page.register(
      name: 'Super Amazing User',
      email: 'super+amazing@user.ca',
      password: 'Supersecret',
      birthdate: '1976-09-06',
      shoe_size:  '10.5'
    )

    expect(page).to have_content(I18n.t('devise.registrations.signed_up'))
  end

end
