class WaitlistEntriesController < ApplicationController

  before_filter :find_scheduled_class

  def index
    @waitlist_entries = @scheduled_class.waitlist_entries
    @users_waitlist_entry = @waitlist_entries.find_by(user: current_user)
  end

  def create
    if @scheduled_class.bookings.where(user: current_user).present?
      flash[:error] = t('waitlist.already_booked')
    elsif WaitlistEntry.add(current_user, @scheduled_class)
      flash[:notice] = t('waitlist.add')
    else
      flash[:error] = t('waitlist.add_failed')
    end
    redirect_to new_scheduled_class_booking_path(@scheduled_class)
  end

  def accept
    waitlist_entry = find_users_waitlist_entry
    if waitlist_entry.present?
      booking = waitlist_entry.booking
      ActiveRecord::Base.transaction do
        booking.user = current_user
        booking.save!
        booking.waitlist_entries.each do |e|
          e.update_attributes(booking_id: nil, status: :queued)
        end
      end
      waitlist_entry.destroy!
      attempt_booking(booking)
    else
      flash[:notice] = "Your do not have a waitlist entry for this class"
      redirect_to new_scheduled_class_booking_path(@scheduled_class)
    end
  end

  def decline
    if (users_entry = find_users_waitlist_entry).present?
      WaitlistEntry::Service.new(@scheduled_class).decline(users_entry)
      flash[:notice] = "Waitlist position successfully declined"
    else
      flash[:error] = "You don't appear to be on the waitlist"
    end
    redirect_to new_scheduled_class_booking_path(@scheduled_class)
  end

  def destroy
    if WaitlistEntry.remove(current_user, @scheduled_class)
      flash[:notice] = t('waitlist.remove')
    else
      flash[:error] = t('waitlist.remove_failed')
    end
    redirect_to user_profile_url
  end

  private

  def failed(booking)
    booking.errors.full_messages.to_sentence
  end

  def successful(booking)
    cls = booking.scheduled_class
    t('successful_booking',
      class_name: cls.name,
      instructor_name: cls.instructor_name,
      start_time: l(cls.start_time, format: :long)
    )
  end

  def find_users_waitlist_entry
    @scheduled_class
     .waitlist_entries
     .where('booking_id IS NOT NULL')
     .find_by(user: current_user)
  end

  def find_scheduled_class
    @scheduled_class = ScheduledClass.find(params[:scheduled_class_id])
  end

end

