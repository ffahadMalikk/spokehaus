class WeeklyCalendar

  def initialize(week, scheduled_classes)
    @week = week
    @scheduled_classes = scheduled_classes
  end

  def self.for_user(date, user)
    week = WeekOf.new(date)
    classes = WeeklyCalendarQuery.execute(week, user)
    new(week, classes.group_by(&:start_date))
  end

  def range
    first = @week.start
    last  = @week.end
    last_format = first.month == last.month ? :day_number : :short_day
    first_formatted = I18n.l(first, format: :short_day)
    last_formatted = I18n.l(last, format: last_format)
    "#{first_formatted}<span>&ndash;</span>#{last_formatted}"
  end

  def days
    @week.range.map do |time|
      classes = @scheduled_classes.fetch(time.to_date, [])
      Day.new(time, classes)
    end
  end

  def previous
    new_day = @week.start - 1.day
    if new_day >= Opening.today_or_opening
      Rails.application.routes.url_helpers.calendar_path(new_day.to_date)
    end
  end

  def has_previous?
    previous.present?
  end

  def next
    new_day = @week.end + 1.day
    if new_day <= Opening.today_or_opening + SchedulingWindow::LENGTH
      Rails.application.routes.url_helpers.calendar_path(new_day.to_date)
    end
  end

  def has_next?
    self.next.present?
  end

  private

  class Day
    attr_reader :date

    def initialize(date, classes)
      @date = date
      @classes = classes
    end

    def name
      date.strftime('%A')
    end

    def scheduled_classes
      @classes.sort do |a, b|
        a.start_time <=> b.start_time
      end
    end

  end

end
