require "rails_helper"

RSpec.describe GiftMailer, type: :mailer do
  describe "notify_of_delivery" do
    let(:gift)      { create(:gift) }
    let(:recipient) { User.find_by(email: gift.recipient_email) }
    let(:mail)      { GiftMailer.notify_of_delivery(gift.id) }

    it "renders the headers" do
      expect(mail.subject).to eq("Someone sent you a free Spokehaus credit!")
      expect(mail.to).to eq([recipient.email])
      expect(mail.from).to eq(["cityplace@spokehaus.ca"])
    end

    it "renders the body" do
      body = "#{gift.sender.name} has sent you #{gift.credits} credit"
      expect(mail.body.encoded).to match(body)
    end
  end

end
