# config/initializers/api_client.rb
require 'json'
require 'open3'

module ApiClient
  # Utiliser le port 8080 pour l'API Python
  API_URL = ENV['API_URL'] || 'http://localhost:8080'
  
  def self.post_image(image_path, confidence = 0.25, max_retries = 3)
    begin
      Rails.logger.info("Envoi de l'image à l'API: #{image_path}")
      
      # Vérifier que le fichier existe
      unless File.exist?(image_path)
        Rails.logger.error("Le fichier n'existe pas: #{image_path}")
        return { 'success' => false, 'error' => "Le fichier n'existe pas: #{image_path}" }
      end
      
      # Tentatives avec délai exponentiel
      retries = 0
      last_error = nil
      
      while retries < max_retries
        begin
          # Utiliser directement curl qui fonctionne
          Rails.logger.info("Tentative #{retries + 1}/#{max_retries} d'envoi de l'image avec curl")
          
          # Déterminer le type MIME du fichier
          mime_type = `file --mime-type -b "#{image_path}"`.strip
          Rails.logger.info("Type MIME détecté: #{mime_type}")
          
          # Construire la commande curl exactement comme celle qui fonctionne
          curl_command = "curl -X 'POST' " +
                         "'#{API_URL}/analyze' " +
                         "-H 'accept: application/json' " +
                         "-H 'Content-Type: multipart/form-data' " +
                         "-F 'file=@#{image_path};type=#{mime_type}' " +
                         "-F 'confidence=#{confidence}'"
          
          Rails.logger.info("Exécution de la commande curl: #{curl_command}")
          
          # Exécuter la commande curl
          stdout, stderr, status = Open3.capture3(curl_command)
          
          Rails.logger.info("Statut curl: #{status.exitstatus}")
          Rails.logger.info("Sortie standard curl: #{stdout}")
          Rails.logger.info("Erreur standard curl: #{stderr}")
          
          if status.success? && !stdout.empty?
            begin
              result = JSON.parse(stdout)
              Rails.logger.info("Réponse de l'API via curl: #{result}")
              
              # Vérifier si la réponse indique un succès
              if result['success'] == false
                Rails.logger.error("Erreur de l'API: #{result['error']}")
                last_error = result['error']
                retries += 1
                sleep(2 ** retries) # Délai exponentiel
                next
              end
              
              return result
            rescue JSON::ParserError => e
              Rails.logger.error("Erreur de parsing JSON: #{e.message}")
              last_error = "Réponse invalide de l'API: #{e.message}"
              retries += 1
              sleep(2 ** retries) # Délai exponentiel
              next
            end
          else
            Rails.logger.error("Erreur curl: #{stderr}")
            last_error = "Impossible de communiquer avec l'API: #{stderr}"
            retries += 1
            sleep(2 ** retries) # Délai exponentiel
            next
          end
        rescue => e
          Rails.logger.error("Erreur lors de la tentative #{retries + 1}: #{e.message}")
          last_error = e.message
          retries += 1
          sleep(2 ** retries) # Délai exponentiel
          next
        end
      end
      
      # Si toutes les tentatives ont échoué
      Rails.logger.error("Toutes les tentatives ont échoué. Dernière erreur: #{last_error}")
      return { 'success' => false, 'error' => "Après #{max_retries} tentatives: #{last_error}" }
    rescue => e
      Rails.logger.error("API request failed: #{e.message}")
      { 'success' => false, 'error' => e.message }
    end
  end
end