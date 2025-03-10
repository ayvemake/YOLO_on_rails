# Backend Python - Architecture et composants

## Architecture générale
- API RESTful construite avec FastAPI
- Deux modèles d'IA principaux:
  - YOLOv8 pour la détection de composants électroniques
  - U-Net pour la segmentation de défauts

## Flux d'analyse
1. Réception d'une image via l'endpoint `/detect`
2. Prétraitement de l'image
3. Analyse par YOLOv8 pour détecter et localiser les composants
4. Pour chaque composant détecté, analyse U-Net pour identifier les défauts potentiels
5. Génération d'une image annotée et d'un rapport détaillé
6. Renvoi des résultats au client Rails

## Modèles IA

### YOLOv8
- Version: YOLOv8n (nano)
- Classes: Résistances, condensateurs, circuits intégrés, etc.
- Métriques:
  - mAP@0.5: 0.92
  - Inférence: ~25ms sur GPU

### U-Net
- Architecture: U-Net avec backbone ResNet18
- Types de défauts: Soudures froides, composants mal alignés, etc.
- Métriques:
  - IoU: 0.85
  - Précision: 0.91
  - Rappel: 0.87

## Endpoints API
- `/detect` - Détection de composants avec YOLOv8
- `/segment` - Détection de défauts avec U-Net
- `/analyze` - Pipeline complet (détection + segmentation)

## Dépendances principales
- Python 3.9+
- FastAPI
- PyTorch 2.0+
- Ultralytics (YOLOv8)
- OpenCV
- NumPy 