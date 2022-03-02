class FileSystemLogger

  def initialize(filename)
    @logger = Logger.new(File.join(Rails.root, 'log', filename))
  end

  def info(message)
    @logger.info(message)
  end

  def error(message, error: nil, options: {})
    msg = if error.present?
      "#{message} - #{error}"
    else
      message
    end
    @logger.error(msg)
  end

end
