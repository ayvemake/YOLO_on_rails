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
  rescue StandardError => e
    handle_error(e)
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

    response = ApiClient.post_image(image_path)
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
      download_result_image(result) if result['image_url']
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

  def handle_error(exception)
    Rails.logger.error("Error during analysis: #{exception.message}")
    Rails.logger.error(exception.backtrace.join("\n"))

    @analysis.update(
      status: 'failed',
      error_message: exception.message,
      processed_at: Time.current
    )
  end
end
