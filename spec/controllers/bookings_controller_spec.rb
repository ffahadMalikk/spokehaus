require 'rails_helper'

RSpec::Matchers.define :a_guest_user do
  match { |user| user.guest? }
end

RSpec::Matchers.define :same_model_as do |model|
  match { |actual| model.id == actual.id }
end

RSpec.describe BookingsController, type: :controller do

  context 'Guest user' do

    scenario 'create a booking with valid attributes' do
      cls = create(:scheduled_class)
      bikes = create_list(:bike, 1)

      post :create, scheduled_class_id: cls.id, booking: {bike_ids: bikes.map(&:id)}

      booking = Booking.last
      expect(booking).to be_pending
      expect(booking.status).to eq 'guest'
      expect(booking.bikes).to eq bikes
      expect(booking.scheduled_class).to eq cls
      expect(booking.user).to be_a_guest

      expect(response).to redirect_to(new_user_registration_path)
    end

  end

  context 'Authenticated' do

    let(:user) { create(:user, status: :registered) }
    before { sign_in(user) }

    scenario 'create a booking with valid attributes' do
      instructor = create(:staff, name: 'Simone Hill')
      bikes = create_list(:bike, 2)
      cls = create(:scheduled_class,
                   name: 'Going fast',
                   staff: instructor,
                   start_time: Time.zone.local(2015, 1, 1, 20, 30))

      controller.api = stub_api
      expect(controller.api).to receive(:get_remaining_credits).and_return(2)

      post :create, scheduled_class_id: cls.id, booking: {bike_ids: bikes.map(&:id)}

      expect(flash[:notice]).to match I18n.t('successful_booking',
                                             class_name: 'Going fast',
                                             start_time: 'Jan 1 at  8:30pm',
                                             instructor_name: 'Simone Hill')

      expect(response).to redirect_to(user_profile_url)
    end

    scenario 'create a booking without valid attributes' do
      controller.api = stub_api

      cls = create(:scheduled_class)

      non_existant_bike_id = 123
      post :create, scheduled_class_id: cls.id, booking: {bike_ids: [non_existant_bike_id]}

      booking = assigns(:booking)
      expect(booking).to be_present
      expect(booking).to_not be_persisted

      expect(booking.scheduled_class).to eq cls
      expect(flash[:error]).to eq "Bikes can't be blank"
      expect(response).to render_template(:new)
    end

  end

  context 'Pending bookings' do

    scenario 'Only allow guests a single pending booking' do
      bikes = create_list(:bike, 2)
      class1 = create(:scheduled_class)
      class2 = create(:scheduled_class)

      # create an initial, pending booking
      post :create, scheduled_class_id: class1.id, booking: {bike_ids: bikes.map(&:id)}

      first_booking = Booking.guest.last
      user = first_booking.user
      expect(first_booking).to be_present

      # create a second pending booking
      post :create, scheduled_class_id: class2.id, booking: {bike_ids: bikes.map(&:id)}

      second_booking = Booking.guest.last
      expect(second_booking.user).to eq user
      expect { first_booking.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    scenario 'Only allow registered users a single pending booking' do
      controller.api = stub_api
      allow(controller.api).to receive(:get_remaining_credits).and_return(0)

      user = create(:registered_user)
      sign_in user
      bikes = create_list(:bike, 2)

      class1, class2 = 2.times.map { create(:scheduled_class) }

      # create an initial pending booking
      post :create, scheduled_class_id: class1.id, booking: {bike_ids: bikes.map(&:id)}
      first_booking = Booking.pending_credits.last
      expect(first_booking).to be_present

      # create a second pending booking
      post :create, scheduled_class_id: class2.id, booking: {bike_ids: bikes.map(&:id)}
      second_booking = Booking.pending_credits.last

      expect(second_booking.user).to eq user
      expect {first_booking.reload}.to raise_error ActiveRecord::RecordNotFound
    end

  end


  context 'updating multiple bookings' do

    scenario 'a user with a completed booking, updates to more bikes than she has credits for' do
      controller.api = stub_api
      user = create(:registered_user)
      sign_in(user)

      bikes = create_list(:bike, 3)
      booking = create(:booking, {
        user: user,
        bikes: bikes.take(2)
      })

      # update the booking with an extra bike the user doesn't have credits for
      allow(controller.api).to receive(:get_remaining_credits).and_return(0)
      patch :update, id: booking, booking: {bike_ids: bikes}

      # the booking should be unchanged, and the user should be redirected
      # to buy more credits
      booking.reload
      expect(booking).to be_booked
      expect(booking.bikes.length).to be(2)
      expect(flash[:notice]).to match I18n.t('notice.need_more_credits_for_more_bikes')
      expect(response).to redirect_to(packages_url)
    end

  end
  private

  def stub_api
    instance_double(MindBodyApi, 'api',
                    get_remaining_credits: 1,
                    add_clients_to_classes: true,
                    get_class: double('class', booked: 1),
                    enrolled_in?: true,
                    book_client_to_class: true)
  end

end
