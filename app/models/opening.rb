module Opening
  Day = Date.new(2016, 2, 8)

  def self.today_or_opening
    if Date.today > Day
      Date.today
    else
      Day
    end
  end

end
