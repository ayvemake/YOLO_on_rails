# Intégration entre Rails et Python

## Format d'échange de données

### Requête de Rails vers l'API Python
```
{
  "image_id": "string",
  "analysis_type": "string", // "component_detection", "defect_detection", "full"
  "parameters": {
    "confidence_threshold": 0.5,
    "iou_threshold": 0.45,
    "min_defect_area": 10,
    "segmentation_threshold": 0.5
  },
  "context": {
    // Données MCP additionnelles (optionnel)
  }
}
```

### Réponse de l'API Python vers Rails
```
{
  "success": true,
  "analysis_id": "string",
  "processing_time": 1.23, // secondes
  "components": [
    {
      "id": 1,
      "class": "resistor",
      "confidence": 0.92,
      "bbox": [x1, y1, x2, y2],
      "defects": [
        {
          "id": 1,
          "type": "misalignment",
          "confidence": 0.87,
          "area": 23.5,
          "contour": [[x1,y1], [x2,y2], ...],
          "severity": "high"
        }
      ],
      "status": "defective" // "ok", "warning", "defective"
    }
  ],
  "result_image": "/output/result_12345.jpg",
  "summary": {
    "total_components": 5,
    "defective_components": 1,
    "conformity_score": 0.8
  }
}
```

## Points d'intégration

### Côté Rails
- **Classe**: `app/services/ai_service.rb`
- **Méthode principale**: `AiService.analyze_image(image, options = {})`
- **Configuration**: `config/initializers/ai_models_config.rb`

### Côté Python
- **Endpoint principal**: `/api/analyze`
- **Contrôleur**: `backend/api/endpoints/analyze.py`
- **Configuration**: `backend/config/api_config.yml`

## Codes d'erreur
- `400`: Requête mal formée
- `401`: Non autorisé
- `404`: Ressource non trouvée
- `422`: Echec de traitement (image invalide, etc.)
- `500`: Erreur serveur interne
- `503`: Service indisponible (modèles en cours de chargement)
