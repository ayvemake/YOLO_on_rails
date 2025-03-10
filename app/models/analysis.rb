class Analysis < ApplicationRecord
  has_one_attached :image
  has_one_attached :result_image
  has_many :analysis_results, dependent: :destroy
  
  # Définir les statuts possibles
  enum status: { pending: 0, processing: 1, completed: 2, failed: 3 }
  
  # Valider la présence de l'image
  validates :image, presence: true
  
  # Scope pour récupérer les analyses récentes
  scope :recent, -> { order(created_at: :desc).limit(10) }
  
  # Seuil de conformité (peut être ajusté selon vos besoins)
  CONFORMITY_THRESHOLD = 0.85
  
  def conforming?
    return false unless score.present?
    
    # Si l'API retourne des détections dans api_data
    if api_data.present? && api_data['detections'].present?
      # Vérifier si aucune détection n'est défectueuse
      !api_data['detections'].any? { |d| d['is_defective'] }
    else
      # Sinon, utiliser le score directement
      score >= CONFORMITY_THRESHOLD
    end
  end
  
  def processing_time
    api_data&.dig('processing_time')
  end
  
  def detections
    api_data&.dig('detections') || []
  end
  
  def defects
    detections.select { |d| d['class_name'].in?(WAFER_DEFECT_CLASSES) }
  end
  
  def good_components
    detections.reject { |d| d['class_name'].in?(WAFER_DEFECT_CLASSES) }
  end
  
  def defect_count
    defects.count
  end
  
  def total_components
    detections.count
  end
  
  def conformity_rate
    return 0 if total_components.zero?
    ((total_components - defect_count).to_f / total_components * 100).round(1)
  end
  
  # Classes de défauts du wafer
  WAFER_DEFECT_CLASSES = [
    'BLOCK ETCH',
    'COATING BAD',
    'PARTICLE',
    'PIQ PARTICLE',
    'PO CONTAMINATION',
    'SCRATCH',
    'SEZ BURNT'
  ].freeze
end 