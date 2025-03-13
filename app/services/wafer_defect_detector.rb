require 'uri'
require 'net/http'
require 'json'
require 'tempfile'

class WaferDefectDetector
  API_URL = 'http://localhost:8080/detect'.freeze

  def self.detect(image_file, confidence = 0.25)
    image_path = prepare_image(image_file)
    model = load_model

    results = perform_detection(model, image_path, confidence)
    process_results(results, image_path)
  end

  def self.prepare_image(image_file)
    if image_file.is_a?(String)
      image_file
    else
      temp_file = Tempfile.new(['upload', '.jpg'])
      temp_file.binmode
      temp_file.write(image_file.read)
      temp_file.close
      temp_file.path
    end
  end

  def self.load_model
    model_path = Rails.root.join('lib/models/best.pt')
    YOLO.new(model_path.to_s)
  end

  def self.perform_detection(model, image_path, confidence)
    model.predict(image_path, conf: confidence)
  end

  def self.process_results(results, image_path)
    # Traitement des résultats...
  end
end
