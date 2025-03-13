class Analysis < ApplicationRecord
  belongs_to :component, optional: true
  has_many :analysis_results, dependent: :destroy
  has_one_attached :image
  has_one_attached :result_image

  # Définir les statuts possibles
  enum :status, {
    pending: 0,
    processing: 1,
    completed: 2,
    failed: 3
  }, default: :pending

  # Valider la présence de l'image
  validates :image, presence: true

  # Scope pour récupérer les analyses récentes
  scope :recent, -> { order(created_at: :desc) }

  scope :today, -> { where("analyses.created_at >= ?", Date.today) }

  scope :successful, -> { 
    where(status: :completed)
      .where("api_data->>'success' = ?", 'true')
  }
  
  scope :conforming, -> { 
    joins(:analysis_results)
      .where("analysis_results.conformity_score >= ?", CONFORMITY_THRESHOLD)
      .distinct
  }

  scope :with_defects, -> {
    joins(:analysis_results)
      .where(analysis_results: { status: :defective })
      .distinct
  }

  # Seuil de conformité (peut être ajusté selon vos besoins)
  CONFORMITY_THRESHOLD = 0.85

  def conforming?
    return false unless completed? && api_data.present?

    score = api_data['score'].to_f
    score >= 0.5 # seuil de conformité à 50%
  end

  def processing_time
    return nil unless api_data&.dig('result', 'processing_time')
    "#{api_data['result']['processing_time']}s"
  end

  def detection_count
    analysis_results.count
  end

  def primary_detection
    return nil unless api_data&.dig('detections')&.any?

    api_data['detections'].first['class_name']
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
    analysis_results.count
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
      .filter_map(&:processing_time_in_seconds)
      .then { |times| times.any? ? (times.sum / times.size).round(4) : nil }
  end

  def processing_time_in_seconds
    return nil unless api_data&.dig('metrics', 'processing', 'total')

    # Enlever le 's' et convertir en float
    time_str = api_data['metrics']['processing']['total'].to_s
    time_str.delete('s').to_f
  end

  def processing_time_formatted
    return nil unless processing_time_in_seconds

    "#{processing_time_in_seconds}s"
  end

  def defect_types
    analysis_results.pluck(:defect_class).uniq
  end

  def score
    return nil unless completed? && analysis_results.any?
    
    # Le score représente la confiance moyenne du modèle YOLOv8 dans ses détections
    # Une valeur plus élevée indique que le modèle est plus confiant dans ses prédictions
    analysis_results.average(:confidence)
  end

  def confidence_score
    return nil unless completed? && analysis_results.any?
    analysis_results.average(:confidence)
  end

  def has_defects?
    defect_count > 0
  end

  # Méthodes pour les statistiques
  def self.today_success_rate
    today_total = where("analyses.created_at >= ?", Date.today).count
    return 0 if today_total.zero?
    
    (today.successful.count.to_f / today_total * 100).round(1)
  end

  def self.today_conformity_rate
    today_analyzed = today.successful.count
    return 0 if today_analyzed.zero?
    
    (today.conforming.count.to_f / today_analyzed * 100).round(1)
  end

  def self.today_defect_rate
    today_analyzed = today.successful.count
    return 0 if today_analyzed.zero?
    
    (today.with_defects.count.to_f / today_analyzed * 100).round(1)
  end
end
