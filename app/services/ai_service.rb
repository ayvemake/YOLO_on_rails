class AiService
  require 'net/http'
  require 'uri'
  require 'json'

  class << self
    def analyze_image(analysis)
      # Get base API URL from config and strip whitespace
      api_url = ENV.fetch('AI_API_URL', 'http://localhost:8080').strip

      # Build complete URL
      uri = URI.parse("#{api_url}/analyze")

      # Get the image file path
      image_path = ActiveStorage::Blob.service.path_for(analysis.image.key)

      # Create multipart form data with just the raw file
      form_data = [
        ['file', File.open(image_path), { filename: analysis.image.filename.to_s }]
      ]

      # Send request using Net::HTTP::Post.new
      response = nil
      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Post.new(uri)
        request.set_form(form_data, 'multipart/form-data')
        response = http.request(request)
      end

      Rails.logger.info "API Response Code: #{response.code}"
      Rails.logger.info "API Response Body: #{response.body}"

      response
    end

    def websocket_url
      base_url = ENV.fetch('AI_API_URL', 'ws://localhost:8080').strip
      "#{base_url.gsub('http', 'ws')}/ws"
    end

    def download_result_image(analysis, image_url)
      # Implementation for downloading result image
      # ...
    end

    private

    def send_multipart_request(uri, form_data)
      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Post.new(uri)
        request.set_form(form_data, 'multipart/form-data')
        http.request(request)
      end
    rescue StandardError => e
      Rails.logger.error "Request failed: #{e.message}"
      raise
    end
  end
end
