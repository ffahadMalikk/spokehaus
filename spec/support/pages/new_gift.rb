class Pages::NewGift < Pages::Base

  def path
    new_gift_path
  end

  def friend_email=(email)
    fill_in 'email', with: email
  end

  def send_gift
    click_on 'Send gift'
  end

end
