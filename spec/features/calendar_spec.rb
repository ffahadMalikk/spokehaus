require 'rails_helper'

describe 'The calendar' do

  before(:all) { Timecop.freeze(Opening::Day) }
  after(:all)  { Timecop.return }

  context 'When Signed in' do

    scenario 'Selecting a new class to book' do
      # Given that I am signed in
      user = create(:user)
      login_as(user)

      # And there is a class
      cls = create(:scheduled_class)

      # When I visit the calendar
      calendar_page = Pages::Calendar.new
      calendar_page.visit_page

      # And I click on the class's link
      booking_page = calendar_page.select_class(cls)

      # Then I should be on the booking page
      expect(current_path).to eq booking_page.path
    end

  end

end
