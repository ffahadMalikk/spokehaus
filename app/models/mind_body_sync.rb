class MindBodySync
  attr_accessor :scheduling_window

  def initialize(logger, api: MindBodyApi.new)
    @api = api
    @log = logger
    @scheduling_window = SchedulingWindow.new
  end

  def all
    @log.info 'MindBody Sync starting'
    commands = [
      # :sites,
      # :locations,
      :staff,
      :classes,
      :services
    ]

    results = commands.each do |cmd|
      @log.info "\tSyncing #{cmd}..."
      if public_send(cmd)
        @log.info "\tSynced #{cmd}"
        true
      else
        @log.error "\tFailed to sync #{cmd}"
        false
      end
    end

    if results
      @log.info 'MindBody sync completed successfully'
    else
      @log.info 'MindBody sync completed with errors'
    end

  end

  def sites
    ap @api.get_sites
  end

  def locations
    ap @api.get_locations
  end

  def staff
    instructors = @api.get_staff
    Sync::Staff.merge(instructors)
  end

  def classes
    upcoming_classes = @api.get_classes(
      start_time: @scheduling_window.start,
      end_time: @scheduling_window.end
    )
    Sync::ScheduledClass.merge(upcoming_classes, @scheduling_window)
  end

  def services
    packages = @api.get_services
    Sync::Package.merge(packages)
  end

end
