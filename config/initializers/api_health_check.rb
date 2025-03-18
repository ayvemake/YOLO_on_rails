Rails.application.config.after_initialize do
  if Rails.env.development? || Rails.env.production?
    require 'net/http'
    
    api_url = Rails.application.config.api_url
    uri = URI("#{api_url}/health")
    
    begin
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        Rails.logger.info "✅ API is available at #{api_url}"
      else
        Rails.logger.warn "⚠️ API returned non-success status: #{response.code}"
      end
    rescue => e
      Rails.logger.error "❌ API is unavailable at #{api_url}: #{e.message}"
    end
  end
end 