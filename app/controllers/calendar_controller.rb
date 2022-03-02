class CalendarController < ApplicationController

  def show
    if date < opening
      redirect_to calendar_url(date: opening)
    else
      @calendar = WeeklyCalendar.for_user(date, current_or_guest_user)
    end
  end

  private

  def date
    @date ||= if params.has_key?(:date)
      Date.parse(params[:date])
    else
      opening
    end
  end

  def opening
    Opening.today_or_opening
  end

end
