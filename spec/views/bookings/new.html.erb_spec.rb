require 'rails_helper'

RSpec.describe 'bookings/new' do

  it 'show the sign up links to admins' do
    admin = build(:admin)
    sign_in(admin)

    booking = build_booking(admin)
    assign(:booking, booking)

    render

    expect(rendered).to have_sign_up_sheet_link(booking)
  end

  it 'hides the sign up links from non-admins' do
    user = build(:user)
    sign_in(user)

    booking = build_booking(user)
    assign(:booking, booking)

    render

    expect(rendered).to_not have_sign_up_sheet_link(booking)
  end

  it 'hides the sign up links from guests' do
    guest = build(:guest)
    sign_in_guest_user(guest)

    booking = build_booking(guest)
    assign(:booking, booking)

    render

    expect(rendered).to_not have_sign_up_sheet_link(booking)
  end

  private

  def have_sign_up_sheet_link(booking)
    have_css("a[href='/admin/sign_up_sheet/#{booking.scheduled_class.id}']")
  end

  def build_booking(user)
    Booking::Presenter.new(build(:booking), user)
  end

  def sign_in_guest_user(user)
    view.extend GuestUser
    expect(view).to receive(:current_user).at_least(1).times.and_return(user)
  end

  def sign_in(user)
    view.extend GuestUser
    expect(view).to receive(:current_or_guest_user).at_least(1).times.and_return(user)
  end

end
