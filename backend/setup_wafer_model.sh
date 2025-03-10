#!/bin/bash

# Créer le dossier pour les poids du modèle
mkdir -p backend/weights

# Chemin vers le modèle entraîné - à ajuster selon votre environnement
MODEL_PATH=~/Desktop/medtronic/backend/wafer_defect/runs/detect/train6/weights/best.pt

# Vérifier si le modèle existe
if [ -f "$MODEL_PATH" ]; then
  echo "Copie du modèle depuis $MODEL_PATH..."
  cp "$MODEL_PATH" backend/weights/best_wafer_model.pt
else
  echo "ERREUR: Le modèle n'a pas été trouvé à $MODEL_PATH"
  echo "Veuillez spécifier le chemin correct vers le modèle entraîné."
  exit 1
fi

# Vérifier que le script de détection est exécutable
chmod +x backend/detect_wafer.py

echo "Configuration du modèle terminée!"
