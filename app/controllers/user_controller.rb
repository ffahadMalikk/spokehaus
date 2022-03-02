class UserController < ApplicationController

  def profile
    authenticate_user!
    @user = current_user
    @credits = api.get_remaining_credits(@user.id, allow_cached: true)
    @waitlist_entries = @user.waitlist_entries.active
    @client_services = api.get_client_services(client_id: current_user.id)
    @client_services = [@client_services] unless @client_services.is_a?(Array)
    @client_services = @client_services.sort_by! { |h| h[:expiration_date] }
    @purchases = if (result = api.get_client_purchases(current_user.id))[:purchases]
      result = result[:purchases][:sale_item]
      result = [result] unless result.is_a?(Array)
      result.sort_by { |h| h[:sale][:sale_date_time] }
    else
      []
    end
    @schedule = @user
      .bookings
      .booked
      .upcoming
      .where(scheduled_class_id: get_schedule_class_ids)
  end

  private

  def get_schedule_class_ids
    window = SchedulingWindow.new
    booked = api.get_client_schedule(@user.id,
                                     start_date: window.start_date,
                                     end_date: window.end_date)
    booked.map { |v| v[:class_id] }
  end

end
