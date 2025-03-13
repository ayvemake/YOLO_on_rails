#!/usr/bin/env python3
import sys
import requests
import json
import os
import time

def send_image(image_path, confidence=0.25, api_url="http://localhost:8080"):
    """
    Envoie une image à l'API Python et retourne la réponse.
    """
    url = f"{api_url}/analyze"
    
    # Vérifier que le fichier existe
    if not os.path.exists(image_path):
        return {"success": False, "error": f"Le fichier n'existe pas: {image_path}"}
    
    # Ajouter un timestamp pour éviter les problèmes de cache
    timestamp = int(time.time())
    
    try:
        # Ouvrir le fichier en mode binaire
        with open(image_path, 'rb') as f:
            # Créer un dictionnaire pour les fichiers et les données
            files = {'file': (f"image_{timestamp}.jpg", f, 'image/jpeg')}
            data = {'confidence': confidence}
            
            # Envoyer la requête avec un timeout
            response = requests.post(url, files=files, data=data, timeout=30)
        
        # Vérifier si la requête a réussi
        if response.status_code == 200:
            return response.json()
        else:
            return {
                "success": False, 
                "error": f"Erreur HTTP: {response.status_code}", 
                "details": response.text
            }
    except Exception as e:
        return {"success": False, "error": str(e)}

if __name__ == "__main__":
    # Vérifier les arguments
    if len(sys.argv) < 2:
        print(json.dumps({"success": False, "error": "Usage: python api_bridge.py <image_path> [confidence] [api_url]"}))
        sys.exit(1)
    
    # Récupérer les arguments
    image_path = sys.argv[1]
    confidence = sys.argv[2] if len(sys.argv) > 2 else 0.25
    api_url = sys.argv[3] if len(sys.argv) > 3 else "http://localhost:8080"
    
    try:
        # Envoyer l'image et récupérer la réponse
        result = send_image(image_path, confidence, api_url)
        
        # Afficher la réponse en JSON
        print(json.dumps(result))
    except Exception as e:
        # En cas d'erreur, retourner un message d'erreur
        print(json.dumps({"success": False, "error": str(e)})) 