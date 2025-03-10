#!/usr/bin/env python3
import sys
import json
import torch
import cv2
import numpy as np
import base64
from ultralytics import YOLO

def detect_defects(image_path, model_path, confidence=0.25):
    """
    Détecte les défauts sur une image de wafer
    
    Args:
        image_path: Chemin vers l'image à analyser
        model_path: Chemin vers le modèle entraîné
        confidence: Seuil de confiance (0-1)
        
    Returns:
        JSON avec les détections
    """
    try:
        # Charger le modèle
        model = YOLO(model_path)
        
        # Effectuer la détection
        results = model(image_path, conf=float(confidence))
        
        # Préparer les résultats
        detections = []
        
        for result in results:
            boxes = result.boxes
            
            for i, box in enumerate(boxes):
                x1, y1, x2, y2 = box.xyxy[0].tolist()
                confidence = float(box.conf[0])
                class_id = int(box.cls[0])
                class_name = result.names[class_id]
                
                detection = {
                    "class_id": class_id,
                    "class_name": class_name,
                    "confidence": confidence,
                    "bbox": [int(x1), int(y1), int(x2), int(y2)]
                }
                detections.append(detection)
        
        # Générer l'image avec les annotations
        img = cv2.imread(image_path)
        for det in detections:
            x1, y1, x2, y2 = det["bbox"]
            label = f"{det['class_name']} {det['confidence']:.2f}"
            color = (0, 255, 0)  # Vert
            
            cv2.rectangle(img, (x1, y1), (x2, y2), color, 2)
            cv2.putText(img, label, (x1, y1 - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)
        
        # Convertir l'image en base64
        _, buffer = cv2.imencode('.jpg', img)
        img_base64 = base64.b64encode(buffer).decode('utf-8')
        
        return json.dumps({
            "success": True,
            "detections": detections,
            "annotated_image": img_base64
        })
        
    except Exception as e:
        return json.dumps({
            "success": False,
            "error": str(e)
        })

if __name__ == "__main__":
    # Vérifier les arguments
    if len(sys.argv) < 3:
        print(json.dumps({
            "success": False,
            "error": "Arguments insuffisants. Usage: detect_wafer.py <image_path> <model_path> [confidence]"
        }))
        sys.exit(1)
    
    # Récupérer les arguments
    image_path = sys.argv[1]
    model_path = sys.argv[2]
    confidence = float(sys.argv[3]) if len(sys.argv) > 3 else 0.25
    
    # Exécuter la détection et imprimer les résultats
    result = detect_defects(image_path, model_path, confidence)
    print(result)
