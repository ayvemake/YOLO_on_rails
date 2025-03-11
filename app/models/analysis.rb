class Analysis < ApplicationRecord
  belongs_to :component, optional: true
  has_one_attached :image
  has_one_attached :result_image
  has_many :analysis_results, dependent: :destroy
  
  # Définir les statuts possibles
  enum status: {
    pending: 'pending',
    processing: 'processing',
    completed: 'completed',
    failed: 'failed'
  }
  
  # Valider la présence de l'image
  validates :image, presence: true
  
  # Scope pour récupérer les analyses récentes
  scope :recent, -> { order(created_at: :desc) }
  
  scope :successful, -> { 
    where(status: 'completed')
    .where("api_data->>'success' = ?", 'true')
  }
  
  scope :with_detections, -> { 
    where("api_data->>'detections' IS NOT NULL")
    .where("jsonb_array_length(api_data->'detections') > 0")
  }
  
  # Seuil de conformité (peut être ajusté selon vos besoins)
  CONFORMITY_THRESHOLD = 0.85
  
  def conforming?
    return false unless completed? && api_data.present?
    
    score = api_data["score"].to_f
    score >= 0.5 # seuil de conformité à 50%
  end
  
  def processing_time
    return nil unless api_data&.dig("metrics", "processing", "total")
    api_data["metrics"]["processing"]["total"]
  end
  
  def detection_count
    return 0 unless api_data&.dig("detections")
    api_data["detections"].size
  end
  
  def primary_detection
    return nil unless api_data&.dig("detections")&.any?
    api_data["detections"].first["class_name"]
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
    analysis_results.where(status: :not_ok).count
  end
  
  def total_components
    analysis_results.count
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
  
  def self.success_rate
    total = completed.count
    return 0 if total.zero?
    
    successful.count.to_f / total * 100
  end
  
  def self.average_processing_time
    successful
      .where("api_data->>'metrics' IS NOT NULL")
      .map { |a| a.processing_time_in_seconds }
      .compact
      .then { |times| times.any? ? (times.sum / times.size).round(4) : nil }
  end

  def processing_time_in_seconds
    return nil unless api_data&.dig("metrics", "processing", "total")
    
    # Enlever le 's' et convertir en float
    time_str = api_data["metrics"]["processing"]["total"].to_s
    time_str.gsub('s', '').to_f
  end

  def processing_time_formatted
    return nil unless processing_time_in_seconds
    "#{processing_time_in_seconds}s"
  end
end 