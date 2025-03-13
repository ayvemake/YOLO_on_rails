class McpService
  class << self
    def client
      @client ||= initialize_client
    end

    def get_context(query, entities = [])
      return {} unless Rails.application.config.mcp[:enabled]

      response = client.post('/context', {
        query: query,
        entities: entities
      }.to_json)

      if response.code == '200'
        JSON.parse(response.body)
      else
        Rails.logger.error("Erreur MCP: #{response.code} - #{response.body}")
        {}
      end
    rescue StandardError => e
      Rails.logger.error("Exception MCP: #{e.message}")
      {}
    end

    def provide_feedback(context_id, feedback)
      return false unless Rails.application.config.mcp[:enabled]

      response = client.post('/feedback', {
        context_id: context_id,
        feedback: feedback
      }.to_json)

      response.code == '200'
    rescue StandardError => e
      Rails.logger.error("Exception MCP feedback: #{e.message}")
      false
    end

    private

    def initialize_client
      uri = URI(Rails.application.config.mcp[:server_url])
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')

      http.tap do |client|
        client.read_timeout = 30
        client.open_timeout = 30
      end
    end
  end
end
