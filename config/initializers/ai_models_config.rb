# Configuration des modèles d'intelligence artificielle
Rails.application.config.ai_models = {
  yolo: {
    enabled: ENV.fetch('YOLO_ENABLED', 'true') == 'true',
    version: ENV.fetch('YOLO_VERSION', 'v8'),
    confidence_threshold: ENV.fetch('YOLO_CONFIDENCE', '0.5').to_f,
    iou_threshold: ENV.fetch('YOLO_IOU', '0.45').to_f,
    endpoint: ENV.fetch('YOLO_ENDPOINT', '/detect')
  },
  unet: {
    enabled: ENV.fetch('UNET_ENABLED', 'true') == 'true',
    segmentation_threshold: ENV.fetch('UNET_THRESHOLD', '0.5').to_f,
    defect_area_minimum: ENV.fetch('DEFECT_AREA_MIN', '10').to_i,
    endpoint: ENV.fetch('UNET_ENDPOINT', '/segment')
  },
  general: {
    api_base_url: ENV.fetch('AI_API_BASE_URL', 'http://localhost:8080'),
    timeout: ENV.fetch('AI_API_TIMEOUT', '30').to_i,
    max_retries: ENV.fetch('AI_API_MAX_RETRIES', '3').to_i,
    image_max_size: ENV.fetch('IMAGE_MAX_SIZE', '1024').to_i
  }
} 