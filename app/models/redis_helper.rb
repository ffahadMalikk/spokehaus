class RedisHelper
  def self.with_connection(&block)
    Sidekiq.redis(&block)
  end
end
