class Analysis < ApplicationRecord
  has_many :analysis_results, dependent: :destroy
  has_many :components, through: :analysis_results
  
  # Statuts possibles pour une analyse
  enum status: { pending: 'pending', processing: 'processing', completed: 'completed', failed: 'failed' }
  
  # Stocke l'image dans Active Storage
  has_one_attached :image
  has_one_attached :result_image
  
  # Renommer l'attribut pour éviter le conflit avec l'association components
  # Utiliser api_data au lieu de components
  store_accessor :api_data, :processing_time, :detections
  
  # Méthode pour vérifier si l'analyse est conforme
  def conforming?
    return false unless score
    score >= 0.85 # Seuil de conformité à 85%
  end
  
  # Méthode pour obtenir un résumé des résultats
  def summary
    {
      status: status,
      score: score,
      conforming: conforming?,
      components_count: analysis_results.count,
      timestamp: timestamp || created_at,
      processing_time: processing_time
    }
  end
  
  # Méthode pour traiter les résultats de l'API
  def process_api_response(response)
    return unless response && response["status"] == "success"
    
    # Mettre à jour les attributs de l'analyse
    self.status = 'completed'
    self.timestamp = Time.now
    
    # Stocker les données brutes dans api_data
    raw_data = {}
    raw_data['processing_time'] = response['processing_time'] if response['processing_time']
    raw_data['detections'] = response['detections'] || []
    
    # Stocker les données brutes
    self.api_data = raw_data
    
    # Calculer un score global basé sur les détections
    if response['detections'].present?
      # Moyenne des scores de confiance des détections
      self.score = response['detections'].sum { |d| d['confidence'].to_f } / response['detections'].size
    end
    
    save!
    
    # Créer les résultats d'analyse pour chaque détection
    if response['detections'].present?
      response['detections'].each do |detection|
        begin
          create_result_from_detection(detection)
        rescue => e
          Rails.logger.error("Erreur lors de la création du résultat pour la détection: #{e.message}")
          Rails.logger.error(e.backtrace.join("\n"))
        end
      end
    end
    
    true
  end
  
  def create_result_from_detection(detection)
    # Trouver ou créer le composant
    component = Component.find_or_create_by(name: detection["component_name"])
    
    # Extraire les coordonnées de la boîte englobante
    x1, y1, x2, y2 = detection["bbox"]
    
    # Calculer le centre
    center_x = detection["center"] ? detection["center"][0] : ((x1 + x2) / 2.0)
    center_y = detection["center"] ? detection["center"][1] : ((y1 + y2) / 2.0)
    
    # Créer le résultat d'analyse
    result = analysis_results.new(
      component: component,
      position_x: center_x,
      position_y: center_y,
      rotation: 0.0, # La rotation n'est pas fournie par l'API
      conformity_score: detection["confidence"] || 0.0,
      status: "ok", # Par défaut, on considère que c'est OK
      raw_data: detection
    )
    
    # Sauvegarder le résultat
    result.save!
    
    result
  end
  
  private
  
  def process_detections(detections)
    detections.each do |detection|
      component = Component.find_or_create_by(name: detection["component_name"])
      
      # Vérifier si ce composant a un résultat de vérification
      comp_verification = nil
      if verification && verification["components"]
        comp_verification = verification["components"].find { |c| c["component_name"] == detection["component_name"] }
      end
      
      # Déterminer le statut et le score
      status = "ok"
      score = 1.0
      
      if comp_verification
        status = comp_verification["status"] == "OK" ? "ok" : "not_ok"
        score = comp_verification["score"] || 0.0
      end
      
      # Calculer la position relative (en pourcentage de l'image)
      x1, y1, x2, y2 = detection["bbox"]
      center_x = (x1 + x2) / 2.0
      center_y = (y1 + y2) / 2.0
      
      # Créer le résultat d'analyse
      analysis_results.create(
        component: component,
        position_x: center_x,
        position_y: center_y,
        rotation: 0.0, # La rotation n'est pas fournie par l'API
        conformity_score: score,
        status: status,
        raw_data: detection
      )
    end
  end
end 