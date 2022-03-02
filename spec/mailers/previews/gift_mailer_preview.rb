# Preview all emails at http://localhost:3000/rails/mailers/gift_mailer
class GiftMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/gift_mailer/notify_of_delivery
  def notify_of_delivery
    GiftMailer.notify_of_delivery
  end

end
