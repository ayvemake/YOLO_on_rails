require 'redis'

# Créer une instance Redis globale
$redis = Redis.new(
  url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0').strip,
  timeout: 5
)

# S'assurer que la connexion fonctionne
begin
  $redis.ping
  Rails.logger.info "Connected to Redis at #{$redis.connection[:host]}:#{$redis.connection[:port]}"
rescue Redis::CannotConnectError => e
  Rails.logger.error "Failed to connect to Redis: #{e.message}"
  raise
end 