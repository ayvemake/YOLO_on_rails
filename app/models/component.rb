class Component < ApplicationRecord
  has_many :analysis_results
  has_many :analyses, through: :analysis_results
  
  validates :name, presence: true, uniqueness: true
  
  # Méthode pour obtenir les coordonnées de référence du composant
  def reference_coordinates
    # À implémenter selon votre logique de référence
    { x: 0, y: 0, rotation: 0 }
  end
end 