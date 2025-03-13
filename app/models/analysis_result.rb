class AnalysisResult < ApplicationRecord
  belongs_to :analysis
  belongs_to :component, optional: true
  
  # Statuts possibles pour un résultat d'analyse de composant
  enum status: { ok: 0, not_ok: 1 }, _prefix: true
  
  validates :position_x, :position_y, :conformity_score, presence: true
  
  # Méthode pour calculer l'écart par rapport à la position de référence
  def position_deviation
    reference = component.reference_coordinates
    dx = position_x - reference[:x]
    dy = position_y - reference[:y]
    dr = rotation - reference[:rotation]
    
    Math.sqrt(dx*dx + dy*dy)
  end
  
  # Méthode pour vérifier si le résultat est conforme
  def conforming?
    status == 'ok' && conformity_score >= 0.85
  end
end 