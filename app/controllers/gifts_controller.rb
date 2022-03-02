class GiftsController < ApplicationController
  before_action :check_for_credits

  def new
    @gift = Gift.new(sender: current_user)
  end

  def create
    @gift = Gift.new(gift_params.merge(sender: current_user))
    if @gift.deliver
      redirect_to user_profile_url, notice: I18n.t('notice.gift_sent')
    else
      render :new
    end
  end

  private

  def gift_params
    params.require(:gift).permit(:recipient_email).merge(credits: 1)
  end

  def check_for_credits
    unless current_user.has_credits_to_give?
      flash[:error] = I18n.t('error.no_credits_to_gift')
      redirect_to user_profile_url
    end
  end

end
