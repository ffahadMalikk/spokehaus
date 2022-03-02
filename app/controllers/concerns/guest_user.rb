module GuestUser

  def current_or_guest_user
    if current_user
      current_user
    else
      if guest_user.present?
        guest_user
      else
        create_guest_user
      end
    end
  end

  # find guest_user object associated with the current session,
  # creating one as needed
  def guest_user
    @cached_guest_user ||= User.guest.find(user_id)
  rescue ActiveRecord::RecordNotFound # if session[:guest_user_id] invalid
    session[:guest_user_id] = nil
  end

  private

  def user_id
    session[:guest_user_id]
  end

  def create_guest_user
    User.create_guest.tap do |u|
      session[:guest_user_id] = u.id
    end
  end

end
