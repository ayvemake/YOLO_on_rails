class AnalysisResult < ApplicationRecord
  belongs_to :analysis
  belongs_to :component, optional: true

  # Changer les valeurs de l'enum pour éviter le conflit avec 'not_'
  enum :status, {
    conforming: 0,
    defective: 1
  }, default: :conforming

  validates :defect_class, presence: true
  validates :confidence, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :conformity_score, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :position_x, presence: true, numericality: true
  validates :position_y, presence: true, numericality: true

  # Méthode pour vérifier si le résultat est conforme
  def conforming?
    status == 'conforming' && conformity_score >= Analysis::CONFORMITY_THRESHOLD
  end

  def confidence_percentage
    return 0 unless confidence.present?
    (confidence.to_f * 100).round(1)
  end

  def defect_type
    defect_class || 'Unknown'
  end

  # Méthode pour calculer l'écart par rapport à la position de référence
  def position_deviation
    reference = component.reference_coordinates
    dx = position_x - reference[:x]
    dy = position_y - reference[:y]
    rotation
    reference[:rotation]

    Math.sqrt((dx * dx) + (dy * dy))
  end
end
