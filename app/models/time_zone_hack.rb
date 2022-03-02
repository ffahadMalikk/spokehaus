class TimeZoneHack
  # TODO remove the need for this hack
  # Figure out how to enter times in MindBody Online in EST/EDT times.
  # They are actually entered in as EST/EDT, but the API omits the timezone offset

  def initialize(local_zone = nil)
    @local_zone = local_zone || Time.zone.name
  end

  # Converts a UTC time from MindBody which actually represents
  # that same time in EST/EDT. Force it into EST/EDT
  def convert_mindbody_time_to_local(date_time)
    date = if date_time.respond_to?(:strftime)
      date_time
    else
      # this will result in an EST/EDT time being parsed as UTC
      # as we have no time zone info. The idea is to match what comes
      # from the savon gem.
      # https://github.com/savonrb/nori/blob/master/lib/nori/xml_utility_node.rb#L221
      DateTime.parse(date_time)
    end
    output = Time.parse(date.strftime('%FT%R')) # 2007-11-19T08:37
    warning "Forcing UTC to #{@local_zone}", date.utc, output
    output
  end

  # Converts a date_time into a value that MindBody expects
  # Which is to say a UTC time, which actually represents that time in EST/EDT
  # Notice that currently, local daylight savings is dropped:
  #   2016-03-06 00:00:00 -0500 ==> 2016-03-06 00:00:00 UTC
  #   2016-03-26 00:00:00 -0400 ==> 2016-03-26 00:00:00 UTC
  #   This is probably a bug
  def convert_local_to_mindbody(date)
    output = Time.zone.parse(date.strftime("%Y-%m-%d %H:%M:%S UTC"))
    warning "Forcing #{@local_zone} to UTC", date, output.utc
    output
  end

  private

  def warning(message, input, output)
    message = "Warning *** #{message}. #{input} ==> #{output}. See app/models/time_zone_hack.rb for details."

    Rails.logger.warn message
  end

end
