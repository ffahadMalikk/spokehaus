module UserHelper

  def user_has_credits?
    credits = credits_for_user(current_or_guest_user)
    credits.present? && credits > 0
  end

end
