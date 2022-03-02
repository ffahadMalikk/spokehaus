class Pages::EditGift < Pages::Base

  def initialize(gift)
    @gift = gift
  end

  def path
    edit_gift_path(@gift)
  end

  def friend_email=(email)
    puts page.html
    fill_in 'email', with: email
  end

end
