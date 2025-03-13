# config/initializers/api_client.rb
require 'json'
require 'open3'

module ApiClient
  # Utiliser le port 8080 pour l'API Python
  API_URL = ENV['API_URL'] || 'http://localhost:8080'
  
  def self.post_image(image_path, confidence = 0.25)
    begin
      Rails.logger.info("Envoi de l'image à l'API: #{image_path}")
      
      # Vérifier que le fichier existe
      unless File.exist?(image_path)
        Rails.logger.error("Le fichier n'existe pas: #{image_path}")
        return { 'success' => false, 'error' => "Le fichier n'existe pas: #{image_path}" }
      end
      
      # Utiliser le script Python comme intermédiaire
      Rails.logger.info("Utilisation du script Python comme intermédiaire")
      
      # Chemin vers le script Python
      script_path = Rails.root.join('lib', 'api_bridge.py')
      
      # Chemin vers l'interpréteur Python dans l'environnement virtuel
      # Si vous n'utilisez pas d'environnement virtuel, utilisez simplement 'python3'
      python_path = File.exist?(Rails.root.join('.venv', 'bin', 'python')) ? 
                    Rails.root.join('.venv', 'bin', 'python') : 
                    'python3'
      
      # Exécuter le script Python
      command = "#{python_path} #{script_path} #{image_path} #{confidence} #{API_URL}"
      Rails.logger.info("Exécution de la commande: #{command}")
      
      stdout, stderr, status = Open3.capture3(command)
      
      Rails.logger.info("Statut: #{status.exitstatus}")
      Rails.logger.info("Sortie standard: #{stdout}")
      Rails.logger.info("Erreur standard: #{stderr}")
      
      if status.success? && !stdout.empty?
        begin
          result = JSON.parse(stdout)
          Rails.logger.info("Réponse de l'API via Python: #{result}")
          return result
        rescue JSON::ParserError => e
          Rails.logger.error("Erreur de parsing JSON: #{e.message}")
          return { 'success' => false, 'error' => "Réponse invalide de l'API: #{e.message}" }
        end
      else
        Rails.logger.error("Erreur lors de l'exécution du script Python: #{stderr}")
        return { 'success' => false, 'error' => "Impossible de communiquer avec l'API: #{stderr}" }
      end
    rescue => e
      Rails.logger.error("API request failed: #{e.message}")
      { 'success' => false, 'error' => e.message }
    end
  end
end