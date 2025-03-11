module DocumentationHelper
  def defect_descriptions(defect_class)
    {
      'BLOCK ETCH' => 'Zones où la gravure est bloquée ou incomplète sur le wafer.',
      'COATING BAD' => 'Défauts dans le revêtement de surface du wafer.',
      'PARTICLE' => 'Particules étrangères présentes sur la surface.',
      'PIQ PARTICLE' => 'Particules spécifiques affectant la couche PIQ.',
      'PO CONTAMINATION' => 'Contamination du processus d\'oxydation.',
      'SCRATCH' => 'Rayures physiques sur la surface du wafer.',
      'SEZ BURNT' => 'Zones brûlées lors du processus SEZ.'
    }[defect_class]
  end
end 