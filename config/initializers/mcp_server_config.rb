# Configuration pour Model Context Protocol
Rails.application.config.mcp = {
  enabled: ENV.fetch('MCP_ENABLED', 'true') == 'true',
  server_url: ENV.fetch('MCP_SERVER_URL', 'http://localhost:5000'),
  api_key: ENV.fetch('MCP_API_KEY', nil),
  default_model: ENV.fetch('MCP_DEFAULT_MODEL', 'gpt-3.5-turbo'),
  home_assistant_url: ENV.fetch('HOME_ASSISTANT_URL', nil),
  home_assistant_token: ENV.fetch('HOME_ASSISTANT_TOKEN', nil)
}

# Configuration des serveurs API externes
Rails.application.config.api_servers = {
  fastapi: ENV.fetch('MCP_FASTAPI_URL', 'http://localhost:8000'),
  result_service: ENV.fetch('MCP_RESULT_SERVICE_URL', 'http://localhost:8001')
} 