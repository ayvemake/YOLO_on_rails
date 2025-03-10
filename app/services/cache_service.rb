class CacheService
  def self.set_value(key, value, expires_in: 1.hour)
    $redis.setex(key, expires_in.to_i, value)
  end

  def self.get_value(key)
    $redis.get(key)
  end
end 