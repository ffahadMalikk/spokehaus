require 'rails_helper'

RSpec.describe "Giving a friend credit to another user" do

  scenario "Sending a credit to an existing user" do
    if Flags.friend_credits?
      with_friend_credits
    end
  end

  private

  def with_friend_credits
    Sidekiq::Testing.inline! do
      # Given that I am logged in as a registered user with a friend credit
      me = create(:registered_user, friend_credits: 2)
      login_as(me)

      # and I have a friend who is an existing, registered user
      my_friend = create(:registered_user)
      # and the 1 ride package exists
      create(:one_ride_package)

      # When I visit my profile
      profile_page = Pages::Profile.new
      visit profile_page.path

      # And I click on the give credits button
      gift_page = profile_page.send_gift

      # Then I should be taken to the new form
      expect(current_path).to eq gift_page.path

      # And When I fill in my friend's email
      gift_page.friend_email = my_friend.email

      # And I submit the form
      gift_page.send_gift

      # Then I should see a confirmation message
      expect(page).to have_content(I18n.t("notice.gift_sent"))

      # And they should have an extra credit
      api = MindBodyApi.new
      expect(api.get_remaining_credits(my_friend.id)).to eq 1

      # And I should be docked 1 friend credit
      expect(me.reload.friend_credits).to eq(1)
    end
  end

end
