class DeliverGiftJob
  include Sidekiq::Worker

  def perform(gift_id)
    gift = Gift.find(gift_id)

    recipient = User.find_by!(email: gift.recipient_email)
    package = Package.one_ride
    payment = Payments::Comped.new(package.total)

    api = MindBodyApi.new
    api.purchase(recipient.id, item: package, payment: payment)
    gift.delivered!

    GiftMailer.delay.notify_of_delivery(gift.id)
  end
end

