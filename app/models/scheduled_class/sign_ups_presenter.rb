class ScheduledClass::SignUpsPresenter
  attr_reader :sign_ups

  def initialize(sign_ups_query)
    @sign_ups = sign_ups_query.run
    @scheduled_class = sign_ups_query.scheduled_class
  end

  def class_name
    @scheduled_class.name
  end

  def class_time
    I18n.l(@scheduled_class.start_time, format: :booking)
  end

  def class_instructor
    @scheduled_class.staff.name
  end

  def each(&block)
    @sign_ups.each(&block)
  end

  def any?
    @sign_ups.any?
  end

end
