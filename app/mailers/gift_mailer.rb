class GiftMailer < ApplicationMailer

  def notify_of_delivery(gift_id)
    gift = Gift.find(gift_id)

    recipient = User.find_by!(email: gift.recipient_email)

    @name = recipient.name
    @sender = gift.sender.name
    @credits = gift.credits

    mail to: gift.recipient_email,
         subject: "Someone sent you a free Spokehaus credit!",
         from: "cityplace@spokehaus.ca"
  end
end
