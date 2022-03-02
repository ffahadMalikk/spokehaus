WeekOf = Struct.new(:date) do

  def range
    days = 6.times.map do |i|
      first_day + i.days
    end

    days + [last_day]
  end

  def first_day
    date.beginning_of_week(:sunday).beginning_of_day
  end
  alias_method :start, :first_day

  def last_day
    date.end_of_week(:sunday).end_of_day
  end
  alias_method :end, :last_day

end
