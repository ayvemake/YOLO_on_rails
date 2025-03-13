class HomeAssistantService
  class << self
    def client
      @client ||= initialize_client
    end

    def get_state(entity_id)
      return nil unless ha_configured?

      response = get("/api/states/#{entity_id}")
      JSON.parse(response.body) if response.code == '200'
    rescue StandardError => e
      Rails.logger.error("Erreur Home Assistant: #{e.message}")
      nil
    end

    def states
      return [] unless ha_configured?

      response = get('/api/states')
      JSON.parse(response.body) if response.code == '200'
    rescue StandardError => e
      Rails.logger.error("Erreur Home Assistant: #{e.message}")
      []
    end

    private

    def ha_configured?
      Rails.application.config.mcp[:home_assistant_url].present? &&
        Rails.application.config.mcp[:home_assistant_token].present?
    end

    def get(path)
      uri = URI("#{Rails.application.config.mcp[:home_assistant_url]}#{path}")
      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = "Bearer #{Rails.application.config.mcp[:home_assistant_token]}"
      request['Content-Type'] = 'application/json'

      client.request(request)
    end

    def initialize_client
      uri = URI(Rails.application.config.mcp[:home_assistant_url])
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')

      http.tap do |client|
        client.read_timeout = 30
        client.open_timeout = 30
      end
    end
  end
end
