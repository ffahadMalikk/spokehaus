require 'rails_helper'

describe 'Viewing the sign-up sheet for a given class' do

  let!(:api) { instance_double(MindBodyApi) }

  before {
    allow(MindBodyApi).to receive(:new)
                            .at_least(:once)
                            .and_return(api)
    allow(api).to receive(:get_remaining_credits).and_return(0)
    Timecop.travel Time.zone.local(2016, 2, 8)
  }

  after {
    Timecop.return
  }

  scenario 'a class with many signups' do
    # Given an admin is logged in
    admin = create(:admin)
    login_as(admin)

    # and there is a class with bikes
    cls = create(:scheduled_class, name: 'Cosmic Bikesplosion')
    alices_bikes = [create(:bike, position: 3), create(:bike, position: 2)]
    charlies_bikes = Array.wrap(create(:bike, position: 1))
    create_list(:bike, 3) # empty bikes

    alice = create(:registered_user, name: 'Alice Walker', shoe_size: 6.0)
    charlie = create(:registered_user,
      name: 'Charlie Watts',
      shoe_size: 11.5,
      cc_last_four: 2345,
      cc_expiry: Date.today
    )

    # and 3 people are signed up
    create(:booking, user: alice, bikes: alices_bikes, scheduled_class: cls, status: :booked)
    create(:booking, user: charlie, bikes: charlies_bikes, scheduled_class: cls, status: :booked)

    # when I visit the calendar and select my class
    visit calendar_path
    click_on 'Cosmic Bikesplosion'

    # I should be able to click on the sign up sheet link
    click_on 'Sign-up Sheet'

    # Then I should see the sign up sheet with Alice and Charlie
    # including their choice of bike and shoe size
    expect(current_path).to eq "/admin/sign_up_sheet/#{cls.id}"

    # I see 2 users, with their choice of bike and shoe size
    rows = all('[role=sign-up]', count: 3)
    expect(rows[0]).to have_content('Charlie Watts 1 11.5 yes')
    expect(rows[1]).to have_content('Alice Walker 2 6.0 no')
    expect(rows[2]).to have_content('Alice Walker 3 6.0 no')
  end

end
