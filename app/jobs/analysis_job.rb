require 'open3'
require_relative 'concerns/analysis_processing'

class AnalysisJob < ApplicationJob
  include AnalysisProcessing

  queue_as :default

  def perform(analysis_id)
    # Si analysis_id est un objet Analysis, récupérer son ID
    analysis_id = analysis_id.id if analysis_id.is_a?(Analysis)
    @analysis = Analysis.find(analysis_id)

    unless valid_analysis?
      mark_analysis_as_failed('No image attached')
      return
    end

    process_analysis
  rescue => e
    # Update analysis with error status
    @analysis.update(
      status: :failed,
      error_message: "API service unavailable: #{e.message}",
      processed_at: Time.current
    )
    
    # Notify administrators
    AdminMailer.api_error(@analysis, e.message).deliver_later if defined?(AdminMailer)
    
    # Log the error
    Rails.logger.error("API Error for Analysis ##{@analysis.id}: #{e.message}")
  end

  private

  def valid_analysis?
    @analysis.image.attached?
  end

  def mark_analysis_as_failed(message)
    Rails.logger.error(message)
    @analysis.update(
      status: 'failed',
      error_message: message,
      processed_at: Time.current
    )
  end

  def process_analysis
    @analysis.update(status: 'processing')

    image_path = ActiveStorage::Blob.service.path_for(@analysis.image.key)
    log_analysis_info(image_path)

    response = send_image_to_api(image_path)
    log_api_response(response)

    if response['success']
      handle_successful_response(response)
    else
      handle_failed_response(response)
    end
  end

  def log_analysis_info(image_path)
    Rails.logger.info("Starting analysis for ID: #{@analysis.id}")
    Rails.logger.info("Image attached: #{@analysis.image.attached?}")
    Rails.logger.info("Image path: #{image_path}")
  end

  def log_api_response(response)
    Rails.logger.info("Complete API response: #{response.inspect}")
  end

  def handle_successful_response(response)
    result = response['result']
    detections = result['detections'] || []
    score = calculate_score(detections)

    @analysis.with_lock do
      update_analysis_with_results(response)
      download_result_image(result['image_url']) if result['image_url']
      create_analysis_results(response)
    end
  end

  def calculate_score(detections)
    detections.empty? ? 0 : detections.sum { |d| d['confidence'] } / detections.size
  end

  def update_analysis_with_results(response)
    @analysis.update!(
      status: :completed,
      api_data: response,
      processed_at: Time.current
    )
  end

  def create_analysis_results(response)
    return unless response['result'] && response['result']['detections']

    response['result']['detections'].each do |detection|
      @analysis.analysis_results.create!(
        defect_class: detection['class_name'],
        confidence: detection['confidence'],
        position_x: detection['bbox'][0],
        position_y: detection['bbox'][1],
        conformity_score: detection['confidence'],
        status: detection['is_defective'] ? :defective : :conforming
      )
    end
  end

  def handle_failed_response(response)
    error_message = response['error'] || response['detail']&.first&.dig('msg') || 'Unknown error'
    @analysis.update(
      status: 'failed',
      error_message: error_message,
      api_data: response,
      processed_at: Time.current
    )
  end

  def send_image_to_api(image_path)
    # Instead of hardcoding http://localhost:8080/analyze
    api_url = "#{Rails.application.config.api_url}/analyze"
    
    # Detect MIME type
    mime_type = detect_mime_type(image_path)
    Rails.logger.info("Type MIME détecté: #{mime_type}")
    
    # Use the api_url variable in your curl command
    curl_command = "curl -X 'POST' '#{api_url}' -H 'accept: application/json' -H 'Content-Type: multipart/form-data' -F 'file=@#{image_path};type=#{mime_type}' -F 'confidence=0.25'"
    
    Rails.logger.info("Exécution de la commande curl: #{curl_command}")
    
    # Execute curl command
    max_attempts = 3
    attempt = 0
    
    while attempt < max_attempts
      attempt += 1
      Rails.logger.info("Tentative #{attempt}/#{max_attempts} d'envoi de l'image avec curl")
      
      stdout, stderr, status = Open3.capture3(curl_command)
      
      Rails.logger.info("Statut curl: #{status.exitstatus}")
      Rails.logger.info("Sortie standard curl: #{stdout}")
      Rails.logger.info("Erreur standard curl: #{stderr}")
      
      if status.success? && !stdout.empty?
        begin
          return JSON.parse(stdout)
        rescue JSON::ParserError => e
          Rails.logger.error("Erreur de parsing JSON: #{e.message}")
          Rails.logger.error("Réponse brute: #{stdout}")
        end
      else
        Rails.logger.error("Erreur curl: #{stderr}")
      end
      
      # Wait before retrying
      sleep(2) unless attempt == max_attempts
    end
    
    # If all attempts failed
    Rails.logger.error("Toutes les tentatives ont échoué. Dernière erreur: Impossible de communiquer avec l'API: #{stderr}")
    
    # Return error response
    {
      'success' => false,
      'error' => "Après #{max_attempts} tentatives: Impossible de communiquer avec l'API: #{stderr}"
    }
  end

  def detect_mime_type(file_path)
    # Use file command to detect MIME type
    mime_type = `file --mime-type -b "#{file_path}"`.strip
    
    # If file command fails, fallback to extension-based detection
    if mime_type.empty? || mime_type == 'application/octet-stream'
      ext = File.extname(file_path).downcase
      case ext
      when '.jpg', '.jpeg'
        mime_type = 'image/jpeg'
      when '.png'
        mime_type = 'image/png'
      when '.gif'
        mime_type = 'image/gif'
      when '.tiff', '.tif'
        mime_type = 'image/tiff'
      when '.bmp'
        mime_type = 'image/bmp'
      else
        mime_type = 'application/octet-stream'
      end
    end
    
    mime_type
  end

  def download_result_image(image_url)
    return unless image_url.present?
    
    # The API returns a relative URL like "/images/annotated_xxx.jpg"
    # We need to prepend the API base URL
    full_url = if image_url.start_with?('http')
                 image_url
               else
                 "#{Rails.application.config.api_url}#{image_url}"
               end
    
    Rails.logger.info("Downloading result image: #{full_url}")
    
    begin
      # Create a temporary file to store the downloaded image
      temp_file = Tempfile.new(['result_image', '.jpg'])
      
      # Download the image using curl
      curl_command = "curl -s -o #{temp_file.path} '#{full_url}'"
      system(curl_command)
      
      if File.exist?(temp_file.path) && File.size(temp_file.path) > 0
        # Attach the downloaded image to the analysis
        @analysis.result_image.attach(
          io: File.open(temp_file.path),
          filename: "result_#{@analysis.id}.jpg",
          content_type: 'image/jpeg'
        )
        Rails.logger.info("Successfully attached result image to analysis ##{@analysis.id}")
      else
        Rails.logger.error("Failed to download result image: Empty or non-existent file")
      end
    rescue => e
      Rails.logger.error("Error downloading result image: #{e.message}")
    ensure
      # Clean up the temporary file
      temp_file.close
      temp_file.unlink
    end
  end
end
