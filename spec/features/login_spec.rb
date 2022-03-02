require 'rails_helper'

describe 'Sign in as an existing user' do

  scenario 'With valid credentials' do
    create :user,
           name: 'Ben Moss',
           email: 'super+amazing@user.ca',
           password: 'Supersecret'

    api = instance_double(MindBodyApi,
            get_shoe_size: "7.5",
            get_remaining_credits: 0)
    expect(MindBodyApi).to receive(:new).at_least(:once).and_return(api)

    visit home_path

    click_on 'Sign In'

    fill_in 'Email', with: 'super+amazing@user.ca'
    fill_in 'Password', with: 'Supersecret'

    within '#new_user' do
      click_on 'Sign In'
    end

    visit home_path
    expect(page).to have_content('Ben’s Profile')
  end

end
