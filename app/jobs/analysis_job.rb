class AnalysisJob < ApplicationJob
  queue_as :default
  
  def perform(analysis_id, retry_count = 0)
    analysis = Analysis.find(analysis_id)
    analysis.update(status: 'processing')
    
    begin
      # Essayer d'abord avec la méthode standard
      response = send_to_fastapi(analysis)
      
      # Si ça échoue, essayer avec curl
      if response.nil?
        Rails.logger.info("Tentative d'envoi avec curl...")
        response = send_to_fastapi_with_curl(analysis)
      end
      
      # Mettre à jour l'analyse avec les résultats
      if response && response['status'] == 'success'
        # Traiter les résultats
        analysis.process_api_response(response)
        
        # Télécharger l'image résultante si disponible
        if response['result_image']
          download_result_image(analysis, response['result_image'])
        else
          Rails.logger.warn("Pas d'image résultante dans la réponse de l'API")
        end
        
        # Notifier les clients via WebSocket avec plus d'informations
        ActionCable.server.broadcast(
          "analysis_channel",
          { 
            analysis_id: analysis.id,
            status: analysis.status,
            score: analysis.score,
            message: "Analyse terminée avec succès",
            has_result_image: analysis.result_image.attached?,
            result_image_url: analysis.result_image.attached? ? Rails.application.routes.url_helpers.rails_blob_path(analysis.result_image, only_path: true) : nil,
            html: ApplicationController.render(
              partial: 'analyses/analysis_result',
              locals: { analysis: analysis }
            )
          }
        )
      else
        # Si l'analyse a échoué mais que nous n'avons pas atteint le nombre maximum de tentatives
        if retry_count < 3
          Rails.logger.info("L'analyse a échoué, nouvelle tentative #{retry_count + 1}/3 dans 5 secondes...")
          
          # Notifier les clients que nous réessayons
          ActionCable.server.broadcast(
            "analysis_channel",
            { 
              analysis_id: analysis.id,
              status: 'processing',
              message: "Nouvelle tentative d'analyse (#{retry_count + 1}/3)..."
            }
          )
          
          # Réessayer après 5 secondes
          AnalysisJob.set(wait: 5.seconds).perform_later(analysis_id, retry_count + 1)
        else
          # Si nous avons atteint le nombre maximum de tentatives, marquer l'analyse comme échouée
          analysis.update(status: 'failed')
          ActionCable.server.broadcast(
            "analysis_channel",
            { 
              analysis_id: analysis.id,
              status: 'failed',
              message: "L'analyse a échoué après 3 tentatives"
            }
          )
        end
      end
    rescue => e
      Rails.logger.error("Erreur lors de l'analyse: #{e.message}")
      analysis.update(status: 'failed')
      ActionCable.server.broadcast(
        "analysis_channel",
        { 
          analysis_id: analysis.id,
          status: 'failed',
          message: "Erreur: #{e.message}"
        }
      )
    end
  end
  
  private
  
  def send_to_fastapi(analysis)
    require 'net/http'
    require 'uri'
    require 'net/http/post/multipart'
    
    uri = URI.parse("http://127.0.0.1:8000/analyze")
    
    # Créer une requête multipart
    request = Net::HTTP::Post.new(uri)
    
    # Préparer l'image pour l'envoi
    image_io = analysis.image.download
    image_filename = analysis.image.filename.to_s
    
    # Vérifier la taille de l'image
    if image_io.size > 900 * 1024  # 900 KB
      Rails.logger.info("L'image est trop grande (#{image_io.size} octets), utilisation de curl comme alternative")
      return nil  # Forcer l'utilisation de curl comme alternative
    end
    
    # Créer un objet form-data
    form_data = {
      'file' => UploadIO.new(StringIO.new(image_io), analysis.image.content_type, image_filename),
      'confidence' => '0.5',
      'tolerance' => '0.2'
    }
    
    request.set_form(form_data, 'multipart/form-data')
    
    # Ajouter des logs pour le débogage
    Rails.logger.info("Envoi de l'image à FastAPI: #{uri}")
    
    # Envoyer la requête avec un timeout plus long
    response = Net::HTTP.start(uri.hostname, uri.port, open_timeout: 30, read_timeout: 30) do |http|
      http.request(request)
    end
    
    # Ajouter des logs pour le débogage
    Rails.logger.info("Réponse de FastAPI: #{response.code}")
    
    # Analyser la réponse JSON si le code est 200
    if response.code == '200'
      begin
        # Force l'encodage en UTF-8 pour éviter les problèmes d'encodage
        response_body = response.body.force_encoding('UTF-8')
        Rails.logger.info("Corps de la réponse: #{response_body[0..200]}...")
        JSON.parse(response_body)
      rescue => e
        Rails.logger.error("Erreur lors du parsing de la réponse JSON: #{e.message}")
        nil
      end
    else
      Rails.logger.error("Corps de la réponse: #{response.body[0..200]}...")
      nil
    end
  rescue => e
    Rails.logger.error("Erreur lors de l'envoi à FastAPI: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    nil
  end
  
  def send_to_fastapi_with_curl(analysis)
    require 'net/http'
    require 'uri'
    require 'tempfile'
    
    # Créer un fichier temporaire pour l'image redimensionnée
    temp_file = Tempfile.new(['image', '.jpg'])
    
    begin
      # Télécharger l'image
      image_data = analysis.image.download
      
      # Redimensionner l'image avec ImageMagick
      original_temp = Tempfile.new(['original', '.jpg'])
      original_temp.binmode
      original_temp.write(image_data)
      original_temp.close
      
      # Redimensionner l'image
      system("convert #{original_temp.path} -resize 25% #{temp_file.path}")
      
      # Vérifier si la conversion a réussi
      unless File.exist?(temp_file.path) && File.size(temp_file.path) > 0
        Rails.logger.warn("Échec du redimensionnement, utilisation de l'image originale")
        temp_file.binmode
        temp_file.write(image_data)
        temp_file.close
      end
      
      # Créer une requête multipart
      uri = URI.parse("http://localhost:8000/analyze")
      
      # Créer une requête HTTP POST
      request = Net::HTTP::Post.new(uri)
      
      # Lire le fichier image
      file_data = File.read(temp_file.path)
      
      # Générer une frontière (boundary) unique pour le multipart
      boundary = "AaB03x"
      
      # Définir les en-têtes de la requête
      request["Content-Type"] = "multipart/form-data; boundary=#{boundary}"
      
      # Construire le corps de la requête multipart
      post_body = []
      post_body << "--#{boundary}\r\n"
      post_body << "Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n"
      post_body << "Content-Type: image/jpeg\r\n\r\n"
      post_body << file_data
      post_body << "\r\n--#{boundary}\r\n"
      post_body << "Content-Disposition: form-data; name=\"confidence\"\r\n\r\n"
      post_body << "0.5"
      post_body << "\r\n--#{boundary}\r\n"
      post_body << "Content-Disposition: form-data; name=\"tolerance\"\r\n\r\n"
      post_body << "0.2"
      post_body << "\r\n--#{boundary}--\r\n"
      
      # Définir le corps de la requête
      request.body = post_body.join
      
      # Envoyer la requête
      response = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(request)
      end
      
      # Vérifier si la requête a réussi
      if response.code == "200"
        # Analyser la réponse JSON
        JSON.parse(response.body)
      else
        Rails.logger.error("La requête a échoué avec le code: #{response.code}")
        Rails.logger.error("Réponse: #{response.body}")
        nil
      end
    rescue => e
      Rails.logger.error("Erreur lors de l'envoi à FastAPI: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      nil
    ensure
      # Supprimer les fichiers temporaires
      temp_file.unlink if temp_file && temp_file.path
      original_temp.unlink if defined?(original_temp) && original_temp && original_temp.path
    end
  end
  
  def download_result_image(analysis, image_url)
    require 'net/http'
    require 'uri'
    
    # Vérifier si l'URL de l'image est présente
    return unless image_url.present?
    
    Rails.logger.info("Téléchargement de l'image résultante depuis: #{image_url}")
    
    # Analyser l'URL
    uri = URI.parse(image_url)
    
    # Télécharger l'image
    response = Net::HTTP.get_response(uri)
    
    if response.code == "200"
      # Extraire le nom du fichier de l'URL
      filename = File.basename(uri.path)
      
      # Attacher l'image au modèle Analysis
      analysis.result_image.attach(
        io: StringIO.new(response.body),
        filename: filename,
        content_type: response.content_type || 'image/jpeg'
      )
      Rails.logger.info("Image résultante téléchargée avec succès: #{filename}")
    else
      Rails.logger.error("Impossible de télécharger l'image résultante: #{response.code} - #{response.message}")
    end
  rescue => e
    Rails.logger.error("Erreur lors du téléchargement de l'image résultante: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
  end
end 