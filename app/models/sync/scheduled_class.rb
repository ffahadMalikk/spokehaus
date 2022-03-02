class Sync::ScheduledClass < Sync::Base

  def initialize
    super(ScheduledClass)
  end

  def merge(classes, window)
    # only prune classes within the current window
    super(classes, ScheduledClass.between(window.start, window.end))
  end

end
