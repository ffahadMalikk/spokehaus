class BookingsController < ApplicationController

  def new
    @booking = present(build_booking)
  end

  def edit
    @booking = present(load_booking)
  end

  def create
    Booking.clear_pending_for(current_or_guest_user)

    booking = build_booking
    booking.bike_ids = booking_params.fetch(:bike_ids, [])

    if booking.bike_ids.empty?
      flash[:notice] = "Please select a bike"
      redirect_to new_scheduled_class_booking_path(booking.scheduled_class)
    else
      unless booking.valid?
        @booking = present(booking)
        Honeybadger.notify(StandardError.new("temp: invalid booking"), context: {
          booking: booking.attributes,
          errors: booking.errors.full_messages.to_sentence
        })
        flash[:error] = failed(booking)
        redirect_to new_scheduled_class_booking_path(booking.scheduled_class)
        return
      end

      attempt_booking(booking)
    end
  end

  def update
    booking = load_booking

    new_bike_ids = booking_params.fetch(:bike_ids, [])
    old_bike_ids = booking.bike_ids

    if new_bike_ids.empty?
      cancel(booking)
      return
    end

    # Remove the user from the class
    client_ids = old_bike_ids.count.times.map { booking.user.id }
    api.remove_clients_from_classes(client_ids, booking.scheduled_class.id)

    # Set the bike IDs to the new bike ids
    booking.bike_ids = new_bike_ids

    # Attempt to book
    if complete_booking(booking) && booking.save
      redirect_to user_profile_url, notice: successful(booking)
    else
      # Booking with new bike ids failed. Re-book with old bikes and
      # let the user know that it failed
      flash[:error] = booking.status_text
      booking.update_attributes!(status_text: nil, bike_ids: old_bike_ids)
      complete_booking(booking)
      redirect_to new_scheduled_class_booking_path(booking.scheduled_class)
    end
  end

  def destroy
    cancel(load_booking)
  end

  def complete
    booking = Booking.pending.for(current_or_guest_user).first

    unless booking.present?
      if request.env["HTTP_REFERER"]
        redirect_to :back
      else
        redirect_to home_url
      end
      return
    end

    attempt_booking(booking)
  end

  private

  def booking_params
    params.fetch(:booking, {}).permit(
      :scheduled_class_id,
      bike_ids: []
    )
  end

  def class_id
    params.fetch(:scheduled_class_id)
  end

  def build_booking
    cls = ScheduledClass.find(class_id)
    booking = cls.bookings.for(current_or_guest_user).first
    booking ||= cls.bookings.new(user: current_or_guest_user)
    booking
  end

  def load_booking
    Booking.upcoming.for(current_or_guest_user).find(params.fetch(:id))
  end

  def successful(booking)
    cls = booking.scheduled_class
    t('successful_booking',
      class_name: cls.name,
      instructor_name: cls.instructor_name,
      start_time: l(cls.start_time, format: :long)
    )
  end

  def pending_registration
    t('booking_pending_registration')
  end

  def failed(booking)
    msg = booking.errors.full_messages.to_sentence
    msg = booking.status_text if msg.empty?
    msg
  end

  def cancel(booking)
    cancelation = Booking::Cancelation.new(booking, api)
    if cancelation.perform
      redirect_to user_profile_url,
        notice: I18n.t('booking_canceled')
    else
      redirect_to new_scheduled_class_booking_path(cancelation.booking),
        notice: I18n.t('booking_not_canceled')
    end
  end

  def present(booking)
    Booking::Presenter.new(booking, current_or_guest_user)
  end

end
