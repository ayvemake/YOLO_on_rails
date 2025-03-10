## directory-structure.md

# Structure du projet

## Répertoires principaux

### Application Rails (dossier racine)
- **`app/`** - Dossier principal de l'application Rails
  - **`controllers/`** - Contrôleurs Rails
  - **`models/`** - Modèles ActiveRecord
  - **`views/`** - Vues ERB et partials
  - **`jobs/`** - Jobs ActiveJob
  - **`services/`** - Services métier
    - **`ai_service.rb`** - Service d'interface avec les APIs d'IA
    - **`mcp_service.rb`** - Service pour l'intégration MCP
  - **`helpers/`** - Helpers Rails
  - **`javascript/`** - JavaScript et Stimulus controllers

### Backend Python (dossier backend/)
- **`models/`** - Modèles d'IA
  - **`yolov8/`** - Modèle YOLOv8 pour la détection d'objets
  - **`unet/`** - Modèle U-Net pour la détection de défauts
- **`api/`** - Code de l'API
  - **`endpoints/`** - Points d'entrée de l'API
  - **`utils/`** - Fonctions utilitaires
- **`config/`** - Configuration du backend
- **`tests/`** - Tests pour les modèles et l'API

### Fichiers de configuration Rails
- **`config/`** - Dossier de configuration Rails
  - **`initializers/`** - Initializers Rails
    - **`mcp_server_config.rb`** - Configuration MCP
    - **`ai_models_config.rb`** - Configuration des modèles IA
  - **`routes.rb`** - Configuration des routes Rails
  - **`database.yml`** - Configuration base de données

### Fichiers Cursor.dev spécifiques
- **`.notes/`** - Documentation et contexte du projet
- **`.cursorrules`** - Règles de style de code pour Cursor.dev 
- **`.cursorignore`** - Fichiers à ignorer par Cursor.dev
- **`.cursor-multi-root.json`** - Configuration multi-dossiers pour Cursor