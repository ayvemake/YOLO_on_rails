## project-overview.md

# Pacemaker Vision - Contrôle Qualité

## Vision du projet
Application web pour l'analyse automatisée d'images de composants électroniques de pacemakers, avec intégration de l'IA pour la détection et la vérification de la conformité des composants.

## Objectifs principaux
- Automatiser le processus de contrôle qualité
- Réduire le taux d'erreur dans la production
- Fournir des analyses en temps réel
- Conserver un historique des analyses pour la traçabilité

## Besoins utilisateurs
- Interface simple et intuitive
- Visualisation claire des résultats d'analyse
- Notification immédiate des problèmes détectés
- Génération de rapports de conformité

## Stack technologique
- **Backend**: Ruby on Rails 7.1
- **Base de données**: PostgreSQL
- **Frontend**: Hotwire (Turbo et Stimulus), Tailwind CSS
- **API externe**: FastAPI (Python) pour l'analyse d'images
- **Modèles IA**: 
  - YOLOv8 pour la détection des composants
  - U-Net pour la détection des défauts
- **Intégration**: Model Context Protocol (MCP) pour l'enrichissement contextuel
- **Stockage**: Active Storage
- **Temps réel**: Action Cable pour les mises à jour en direct

## Architecture
- Architecture MVC classique Rails
- Services spécialisés pour l'intégration avec APIs externes
- Background jobs pour le traitement asynchrone
- WebSockets pour la mise à jour en temps réel
- Pipeline d'analyse en deux étapes: détection d'objets puis analyse de défauts

## Intégrations clés
- **FastAPI**: Service d'analyse d'images en Python
- **YOLOv8**: Modèle de détection d'objets pour localiser les composants
- **U-Net**: Modèle de segmentation pour identifier les défauts sur les composants
- **Model Context Protocol (MCP)**: Enrichissement contextuel pour l'IA
- **Home Assistant**: Source de données environnementales (optionnel)

## Objectifs de qualité
- Code DRY et maintenable
- Couverture de tests > 80%
- Temps de réponse < 3 secondes
- Précision d'analyse > 95%
- Taux de faux positifs < 2%
