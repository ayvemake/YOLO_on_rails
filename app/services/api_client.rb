def self.post_image(image_path)
  # Make sure this uses the configured URL, not a hardcoded one
  api_url = Rails.application.config.api_url
  # ...
end 