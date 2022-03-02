module CalendarHelper

  def class_time(cls)
    cls.start_time.strftime('%l:%M%P')
  end

  def instructor_name(cls)
    cls.staff.try!(:name) || "TBD"
  end

  def duration(cls)
    "#{cls.duration/60}min"
  end

end
