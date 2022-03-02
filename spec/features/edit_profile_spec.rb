require 'rails_helper'

describe 'Editing a user spec' do

  scenario 'with valid attributes' do
    # Given I am logged in as a registered user
    user = create(:registered_user,
                  name: 'Old Name',
                  email: 'old.email@example.org',
                  shoe_size: 5.0,
                  birthdate: Date.new(1976,9,6),
                  password: 'secret-sauce'
                  )
    login_as(user)

    # When I visit the edit profile page
    visit edit_user_registration_path

    # And change my basic info
    fill_in 'Name', with: 'New Name'
    fill_in 'Email', with: 'new.email@example.org'
    fill_in 'Shoe size', with: '10.5'
    fill_in 'birthdate', with: '1986-09-06'
    fill_in 'password', with: 'secret-sauce'
    click_on 'Update'

    # Then the API should know about those changes

    api_user = FakeMindBodyApi::Application.find_user(user.id)
    expect(api_user.name).to eq 'New Name'
    expect(api_user.email).to eq 'new.email@example.org'
    expect(api_user.shoe_size).to eq "10.5"
    expect(api_user.birthdate).to eq "1986-09-06T00:00:00"
  end
end
