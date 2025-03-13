class AnalysisJob < ApplicationJob
  queue_as :default
  require 'open-uri'

  def perform(analysis_id)
    # Si analysis_id est un objet Analysis, récupérer son ID
    analysis_id = analysis_id.id if analysis_id.is_a?(Analysis)
    
    analysis = Analysis.find(analysis_id)
    
    # Vérifier si l'analyse a une image attachée
    return unless analysis.image.attached?
    
    # Obtenir l'URL temporaire de l'image
    image_url = Rails.application.routes.url_helpers.rails_blob_path(analysis.image, only_path: true)
    image_path = ActiveStorage::Blob.service.path_for(analysis.image.key)
    
    # Ajoutez ces lignes de débogage au début de la méthode perform
    Rails.logger.info("Démarrage de l'analyse pour l'ID: #{analysis_id}")
    Rails.logger.info("Image attachée: #{analysis.image.attached?}")
    Rails.logger.info("Chemin de l'image: #{image_path}")
    
    begin
      # Appeler l'API Python
      response = ApiClient.post_image(image_path)
      
      # Et après l'appel à l'API
      Rails.logger.info("Réponse complète de l'API: #{response.inspect}")
      
      if response['success']
        # Extraire les détections et les informations pertinentes
        detections = response['result']['detections'] || []
        processing_time = response['result']['processing_time']
        
        # Calculer un score basé sur les détections
        defects_count = detections.count { |d| d['is_defective'] }
        total_count = detections.size
        score = total_count > 0 ? (1.0 - (defects_count.to_f / total_count)) * 100 : 100.0
        
        # Mettre à jour l'analyse avec les résultats
        analysis.update(
          status: 'completed',
          score: score,
          api_data: response['result'],
          error_message: nil,
          processed_at: Time.current
        )
        
        # Créer des résultats d'analyse pour chaque détection
        detections.each do |detection|
          bbox = detection['bbox']
          
          # Calculer la position et la rotation (si disponible)
          position_x = (bbox[0] + bbox[2]) / 2.0 if bbox
          position_y = (bbox[1] + bbox[3]) / 2.0 if bbox
          
          # Créer un résultat d'analyse sans référence au component
          analysis.analysis_results.create(
            position_x: position_x,
            position_y: position_y,
            conformity_score: detection['confidence'] * 100,
            status: detection['is_defective'] ? 'not_ok' : 'ok',
            defect_type: detection['class_name']
          )
        end
        
        # Traiter l'image de résultat si disponible
        if response['result']['image_url'].present?
          begin
            # Construire l'URL complète
            image_url = "#{ApiClient::API_URL}#{response['result']['image_url']}"
            Rails.logger.info("Téléchargement de l'image depuis: #{image_url}")
            
            # Télécharger l'image
            downloaded_image = URI.open(image_url)
            
            # Attacher l'image de résultat
            analysis.result_image.attach(
              io: downloaded_image,
              filename: "result_#{analysis.id}.png",
              content_type: 'image/png'
            )
          rescue => e
            Rails.logger.error("Error downloading result image: #{e.message}")
          end
        end
        
        # Diffuser les résultats via ActionCable
        ActionCable.server.broadcast(
          "analysis_#{analysis.id}",
          {
            status: 'completed',
            score: score,
            detections: detections,
            processing_time: processing_time
          }
        )
      else
        # Utiliser le champ error_message existant
        analysis.update(
          status: 'failed',
          error_message: response['error'] || 'Unknown error',
          processed_at: Time.current
        )
        
        ActionCable.server.broadcast(
          "analysis_#{analysis.id}",
          {
            status: 'failed',
            error: response['error'] || 'Unknown error'
          }
        )
      end
    rescue => e
      Rails.logger.error("Error in AnalysisJob: #{e.message}")
      
      # Utiliser le champ error_message existant
      analysis.update(
        status: 'failed',
        error_message: e.message,
        processed_at: Time.current
      )
      
      ActionCable.server.broadcast(
        "analysis_#{analysis.id}",
        {
          status: 'failed',
          error: e.message
        }
      )
    end
  end
end