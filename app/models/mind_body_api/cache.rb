class MindBodyApi::Cache
  attr_reader :hash_key

  def initialize(key = nil)
    @hash_key = 'spokehaus-api-cache-'
    @expire_at = (Time.now + 3.minutes).to_i
  end

  def put(key, value)
    RedisHelper.with_connection do |redis|
      cache_key = hash_key + key
      serialized = {'value' => value}.to_json
      redis.set(cache_key, serialized)
      redis.expireat(cache_key, @expire_at)
    end
  end

  def get(key)
    return_value = nil
    RedisHelper.with_connection do |redis|
      cache_key = hash_key + key
      value = redis.get(cache_key)
      if value.present?
        return_value = JSON.parse(value)['value']
      else
      end
    end
    return_value
  end

  def clear(key)
    RedisHelper.with_connection do |redis|
      cache_key = hash_key + key
      redis.del(cache_key)
    end
  end

  def clear_all
    RedisHelper.with_connection do |redis|
      cache_key = "#{hash_key}*"
      redis.del(cache_key)
    end
  end

end
