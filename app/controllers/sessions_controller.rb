class SessionsController < Devise::SessionsController

  def create
    super do |user|
      if guest_user.present?
        GuestAccountMerger.merge_pending_bookings(guest_user, user)
        session[:guest_user_id] = nil
      end

      user.update!(shoe_size: MindBodyApi.new.get_shoe_size(user: user))
    end
  end

  def after_sign_in_path_for(user)
    case
    when Booking.pending_credits.for(user).any?
      complete_pending_bookings_path
    else
      super(user)
    end
  end

end
