class RegistrationsController < Devise::RegistrationsController

  def build_resource(params = nil)
    self.resource = User::Registration.new(params || {})
  end

  def sign_up(user_name, new_user)
    if guest_user.present?
      GuestAccountMerger.merge(guest_user, new_user)
      session[:guest_user_id] = nil
    end

    comp_first_ride(new_user) if Flags.comp_first_ride?

    super(user_name, new_user)
  end

  def after_sign_up_path_for(user)
    case
    when Booking.pending.for(user).any?
      complete_pending_bookings_path
    else
      calendar_path
    end
  end

  def update_resource(resource, user_params)
    resource.update_with_password(update_params)
  end

  def update
    super.tap do
      # bail if we failed to make our update
      return if resource.changed?

      # update the user's info in MindBody
      api.update_user(
        id: resource.id,
        email: resource.email,
        first_name: resource.fullname.first,
        middle_name: resource.fullname.middle,
        last_name: resource.fullname.last,
        birthday: resource.birthdate,
        shoe_size: resource.shoe_size
      )
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(
      :name,
      :email,
      :shoe_size,
      :birthdate,
      :password,
    )
  end

  def update_params
    params.require(:user).permit(
      :name,
      :shoe_size,
      :birthdate,
      :email,
      :password,
      :password_confirmation,
      :current_password
    )
  end

  def comp_first_ride(user)
    booking = Booking.pending.for(user).first
    CompFirstRide.new(user, booking).apply
  rescue => e
    raise e if Rails.env.test?
    Rails.logger.error(e)
    Honeybadger.notify(e, context: {
      user: user.try(:attributes),
      booking: booking.try(:attributes)
    })
  end

end
