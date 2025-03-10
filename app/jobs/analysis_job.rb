class AnalysisJob < ApplicationJob
  queue_as :default

  # Configuration pour MCP (à définir dans config/initializers/mcp_server_config.rb)
  # MCP_ENABLED = true
  # MCP_SERVER_URL = 'http://mcp-server:5000'
  # MCP_API_KEY = 'votre_clé_api_ici'
  # MCP_DEFAULT_MODEL = 'gpt-4'

  def perform(analysis)
    # Update status to processing
    analysis.update(status: :processing)

    begin
      # Get image URL
      image_url = Rails.application.routes.url_helpers.rails_blob_url(analysis.image)

      # Call FastAPI
      response = AiService.analyze_image(analysis)
  
      case response.code.to_i
      when 200
        process_successful_response(analysis, response)
      when 422
        # Handle validation errors
        handle_api_error(analysis, response)
        analysis.update(status: :failed)
      else
        # Handle other errors
        Rails.logger.error "API Error: #{response.code} - #{response.body}"
        analysis.update(status: :failed)
      end

    rescue StandardError => e
      Rails.logger.error "Analysis failed: #{e.message}"
      analysis.update(status: :failed)
      # Store error in api_data instead of error_message
      analysis.update(api_data: { error: e.message })
    end
  end

  private

  def process_successful_response(analysis, response)
    begin
      data = JSON.parse(response.body)
      
      # Calculate score based on detections
      score = calculate_score(data)
      
      # Update analysis with results
      analysis.update(
        status: :completed,
        score: score,
        api_data: data
      )
      
      # Create individual analysis results
      create_analysis_results(analysis, data)
      
      # If there's a result image URL in the response, download it
      if data['result_image_url']
        download_result_image(analysis, data['result_image_url'])
      end
      
    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse API response: #{e.message}"
      analysis.update(status: :failed)
      analysis.update(api_data: { error: "Failed to parse API response" })
    rescue StandardError => e
      Rails.logger.error "Error processing successful response: #{e.message}"
      analysis.update(status: :failed)
      analysis.update(api_data: { error: e.message })
    end
  end

  def handle_api_error(analysis, response)
    error_message = begin
      data = JSON.parse(response.body)
      if data['detail'].is_a?(Array)
        data['detail'].map { |e| e['msg'] }.join(', ')
      else
        data['detail']
      end
    rescue
      "API Error: #{response.code}"
    end
    
    # Store error in api_data instead of using error_message
    analysis.update(api_data: { error: error_message })
  end

  def calculate_score(data)
    # Calculer le score en fonction des résultats
    return data['score'] if data['score']
    
    detections = data['detections'] || []
    total = detections.size
    defects = detections.count { |d| d['is_defective'] }
    
    total.zero? ? 0 : ((total - defects).to_f / total * 100).round(2)
  end

  def create_analysis_results(analysis, data)
    (data['detections'] || []).each do |detection|
      analysis.analysis_results.create!(
        category: detection['class_name'],
        confidence: detection['confidence'],
        status: detection['is_defective'] ? :defect : :ok,
        bbox_coordinates: detection['bbox']
      )
    end
  end

  def download_result_image(analysis, image_url)
    begin
      # Download the image from the URL
      uri = URI.parse(image_url)
      response = Net::HTTP.get_response(uri)
      
      if response.is_a?(Net::HTTPSuccess)
        # Attach the downloaded image to the analysis
        temp_file = Tempfile.new(['result', '.jpg'])
        temp_file.binmode
        temp_file.write(response.body)
        temp_file.rewind
        
        # Attach the result image to the analysis
        analysis.result_image.attach(
          io: temp_file,
          filename: "result_#{analysis.id}.jpg",
          content_type: 'image/jpeg'
        )
        
        temp_file.close
        temp_file.unlink
      else
        Rails.logger.error "Failed to download result image: #{response.code} #{response.message}"
      end
    rescue StandardError => e
      Rails.logger.error "Error downloading result image: #{e.message}"
    end
  end
end 