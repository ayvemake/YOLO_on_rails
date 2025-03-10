require 'uri'
require 'net/http'
require 'json'

class WaferDefectDetector
  API_URL = 'http://localhost:8080/detect'
  
  def self.detect(image_file, confidence = 0.25)
    # Préparer la requête multipart
    uri = URI.parse(API_URL)
    request = Net::HTTP::Post.new(uri)
    
    # Créer une requête multipart
    form_data = [
      ['confidence', confidence.to_s],
      ['file', image_file, { filename: image_file.original_filename }]
    ]
    
    request.set_form(form_data, 'multipart/form-data')
    
    # Envoyer la requête
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 30
    http.read_timeout = 30
    
    begin
      response = http.request(request)
      
      # Vérifier si la requête a réussi
      unless response.is_a?(Net::HTTPSuccess)
        Rails.logger.error("Erreur API: #{response.code} - #{response.body}")
        raise "L'API a retourné une erreur: #{response.code}"
      end
      
      # Parser la réponse JSON
      result = JSON.parse(response.body)
      
      if result['success']
        return result
      else
        Rails.logger.error("Erreur de détection: #{result['error']}")
        raise "Erreur lors de la détection des défauts: #{result['error']}"
      end
    rescue JSON::ParserError => e
      Rails.logger.error("Erreur de parsing JSON: #{e.message}")
      raise "Erreur lors du parsing de la réponse: #{e.message}"
    rescue => e
      Rails.logger.error("Erreur de connexion: #{e.message}")
      raise "Erreur de connexion à l'API: #{e.message}"
    end
  end
end 