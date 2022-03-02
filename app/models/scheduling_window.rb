class SchedulingWindow
  attr_reader :start, :cutoff
  alias_method :end, :cutoff

  LENGTH = 2.weeks

  def initialize(date = nil)
    week = WeekOf.new(date || Opening.today_or_opening)
    cutoff = week.end + LENGTH
    @start = week.start
    @cutoff = cutoff
  end

  def start_date
    self.start.to_date
  end

  def end_date
    self.end.to_date
  end

end
