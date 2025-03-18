namespace :api do
  desc "Check if the analysis API is available"
  task health: :environment do
    require 'net/http'
    
    api_url = ENV.fetch('API_URL', 'http://localhost:8080')
    uri = URI("#{api_url}/health")
    
    begin
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        puts "API is available and responding correctly"
      else
        puts "API returned non-success status: #{response.code}"
      end
    rescue => e
      puts "API is unavailable: #{e.message}"
    end
  end
end 