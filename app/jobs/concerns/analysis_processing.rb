module AnalysisProcessing
  extend ActiveSupport::Concern

  def download_result_image(result)
    full_image_url = "#{ApiClient::API_URL}#{result['image_url']}"
    Rails.logger.info("Downloading result image: #{full_image_url}")

    begin
      require 'open-uri'
      downloaded_image = URI.parse(full_image_url).open

      @analysis.result_image.attach(
        io: downloaded_image,
        filename: "result_#{@analysis.id}.png",
        content_type: 'image/png'
      )

      Rails.logger.info('Result image attached successfully')
    rescue StandardError => e
      Rails.logger.error("Error downloading result image: #{e.message}")
    end
  end

  def create_detection_results(detections)
    return unless detections.is_a?(Array)

    detections.each do |detection|
      bbox = detection['bbox'] || [0, 0, 0, 0]
      
      @analysis.analysis_results.create!(
        defect_class: detection['class_name'],
        confidence: detection['confidence'],
        x_min: bbox[0],
        y_min: bbox[1],
        x_max: bbox[2],
        y_max: bbox[3],
        api_data: detection
      )
    rescue => e
      Rails.logger.error("Erreur lors de la création du résultat d'analyse: #{e.message}")
    end
  end
end
