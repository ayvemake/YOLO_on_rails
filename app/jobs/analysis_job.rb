class AnalysisJob < ApplicationJob
  queue_as :default

  def perform(analysis_id)
    # Si analysis_id est un objet Analysis, récupérer son ID
    analysis_id = analysis_id.id if analysis_id.is_a?(Analysis)
    
    analysis = Analysis.find(analysis_id)
    
    # Vérifier si l'analyse a une image attachée
    unless analysis.image.attached?
      Rails.logger.error("Pas d'image attachée pour l'analyse #{analysis_id}")
      analysis.update(
        status: 'failed',
        error_message: "Pas d'image attachée",
        processed_at: Time.current
      )
      return
    end
    
    # Obtenir l'URL temporaire de l'image
    image_url = Rails.application.routes.url_helpers.rails_blob_path(analysis.image, only_path: true)
    image_path = ActiveStorage::Blob.service.path_for(analysis.image.key)
    
    Rails.logger.info("Démarrage de l'analyse pour l'ID: #{analysis_id}")
    Rails.logger.info("Image attachée: #{analysis.image.attached?}")
    Rails.logger.info("Chemin de l'image: #{image_path}")
    Rails.logger.info("URL de l'image: #{image_url}")
    
    begin
      # Mettre à jour le statut de l'analyse
      analysis.update(status: 'processing')
      
      # Appeler l'API Python
      Rails.logger.info("Appel de l'API Python avec le chemin: #{image_path}")
      response = ApiClient.post_image(image_path)
      
      Rails.logger.info("Réponse complète de l'API: #{response.inspect}")
      
      # Traiter la réponse
      if response['success']
        # Extraire les données de la réponse
        result = response['result']
        
        # Calculer le score global (moyenne des confiances des détections)
        detections = result['detections'] || []
        score = detections.empty? ? 0 : detections.sum { |d| d['confidence'] } / detections.size
        
        # Mettre à jour l'analyse avec les données de l'API
        analysis.update(
          status: 'completed',
          score: score,
          timestamp: Time.current,
          components: detections.map { |d| d['class_name'] }.join(', '),
          api_data: response,
          processed_at: Time.current
        )
        
        # Télécharger l'image résultante si elle existe
        if result['image_url']
          begin
            # Construire l'URL complète
            full_image_url = "#{ApiClient::API_URL}#{result['image_url']}"
            Rails.logger.info("Téléchargement de l'image résultante: #{full_image_url}")
            
            # Télécharger l'image
            downloaded_image = URI.open(full_image_url)
            
            # Attacher l'image à l'analyse
            analysis.result_image.attach(
              io: downloaded_image,
              filename: "result_#{analysis.id}.png",
              content_type: 'image/png'
            )
            
            Rails.logger.info("Image résultante attachée avec succès")
          rescue => e
            Rails.logger.error("Erreur lors du téléchargement de l'image résultante: #{e.message}")
          end
        end
        
        # Créer les résultats d'analyse
        detections.each do |detection|
          bbox = detection['bbox'] || [0, 0, 0, 0]
          
          analysis.analysis_results.create(
            component_name: detection['class_name'],
            confidence: detection['confidence'],
            x_min: bbox[0],
            y_min: bbox[1],
            x_max: bbox[2],
            y_max: bbox[3]
          )
        end
      else
        # Mettre à jour l'analyse avec l'erreur
        error_message = response['error'] || response['detail']&.first&.dig('msg') || 'Erreur inconnue'
        analysis.update(
          status: 'failed',
          error_message: error_message,
          api_data: response,
          processed_at: Time.current
        )
      end
    rescue => e
      Rails.logger.error("Erreur lors de l'analyse: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      
      # Mettre à jour l'analyse avec l'erreur
      analysis.update(
        status: 'failed',
        error_message: e.message,
        processed_at: Time.current
      )
    end
  end
end