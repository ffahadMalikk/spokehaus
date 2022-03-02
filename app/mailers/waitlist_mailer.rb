class WaitlistMailer < ApplicationMailer

  def notify(entry_id)
    begin
      waitlist_entry = WaitlistEntry.find(entry_id)
      @user = waitlist_entry.user
      @waitlist_entry = waitlist_entry
      mail to: @user.email,
           subject: "Spokehaus: A spot has opened up on the waitlist!",
           from: "cityplace@spokehaus.ca"
    rescue ActiveRecord::RecordNotFound
    end
  end

end
