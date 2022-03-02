class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  attr_accessor :api

  include GuestUser

  helper_method :guest_user, :current_or_guest_user, :credits_for_user

  def pricing_options
    @pricing_options ||= api.get_client_services(client_id: current_user.id)
  end

  def finite_remaining_at(datetime)
    finite_active_at(datetime).sum { |h| h[:remaining].to_i }
  end

  def finite_active_at(datetime)
    pricing_options.select { |opt|
      opt[:count].to_i < Package::UNLIMITED_THRESHOLD &&
      (opt[:expiration_date] > datetime || opt[:expiration_date].nil?)
    }.sort_by { |h| h[:expiration_date] }
  end

  def unlimited_active_at(datetime)
    option = pricing_options.select { |opt|
      opt[:count].to_i > Package::UNLIMITED_THRESHOLD &&
      (opt[:expiration_date] > datetime || opt[:expiration_date].nil?)
    }.sort_by { |h| h[:expiration_date] }
  end

  def create_finite_pricing_option_hash(num_to_book, start_time)
    pricing_options = []
    finite_options = finite_active_at(start_time)
    c = 0
    while num_to_book > 0
      finite_option = finite_options.shift
      num_for_option = if num_to_book > finite_option[:remaining].to_i
        finite_option[:remaining].to_i
      else
        num_to_book
      end
      pricing_options << { id: finite_option[:id], bike_count: num_for_option }
      num_to_book -= num_for_option
      c += 1
      raise "Infinite loop detected. Aborted pricing option calculation!" if c > 100
    end
    pricing_options
  end

  def attempt_booking(booking)
    if current_or_guest_user.guest?
      booking.save_pending_registration
      redirect_to new_user_registration_url
    else
      if complete_booking(booking)
        redirect_to user_profile_url, notice: successful(booking)
      else
        flash[:error] = failed(booking)
        redirect_to new_scheduled_class_booking_path(booking.scheduled_class)
      end
    end
  end

  def complete_booking(booking)
    start_time = booking.scheduled_class.start_time
    bike_count = booking.bike_count

    pricing_options = []
    if unlimited_active_at(start_time).present?
      if booking.bike_count > 1
        if finite_remaining_at(start_time) < (bike_count - 1)
          booking.status_text = "You can only purchase one " +
            "bike in a class on an unlimited package. Subsequent bikes " +
            "require a non-unlimited package with a valid expiry and enough remaining credits."
          return false
        else
          pricing_options << { id: unlimited_active_at(start_time).first[:id], bike_count: 1 }
          pricing_options += create_finite_pricing_option_hash(booking.bike_count - 1, start_time)
        end
      else
        pricing_options << { id: unlimited_active_at(start_time).first[:id], bike_count: 1 }
      end
    else
      if finite_remaining_at(start_time) < bike_count
        booking.status_text = "You don't have enough credits or your credits will be expired at the time of this class."
        return false
      else
        pricing_options = create_finite_pricing_option_hash(bike_count, start_time)
      end
    end
    pending_booking = PendingBooking.new(booking, api)
    pending_booking.complete(pricing_options)
  end

  def after_sign_in_path_for(user)
    home_path
  end

  def after_sign_out_path_for(user)
    home_path
  end

  def credits_for_user(user)
    api.get_remaining_credits(user.id, allow_cached: true)
  end

  def api
    @api ||= MindBodyApi.new
  end

end
