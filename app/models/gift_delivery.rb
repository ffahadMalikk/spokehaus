class GiftDelivery
  COST = 1

  def initialize(gift)
    @gift = gift
    @sender = gift.sender
  end

  def deliver
    if save_and_charge_user
      DeliverGiftJob.perform_async(@gift.id)
    end
  end

  private

  def save_and_charge_user
    Gift.transaction do
      if has_credits? && charge_sender && save
        true
      else
        raise ActiveRecord::Rollback
      end
    end
  end

  def has_credits?
    @sender.friend_credits >= COST
  end

  def charge_sender
    @sender.update(friend_credits: @sender.friend_credits - COST)
  end

  def save
    @gift.save
  end

end

