class DefectDetection < ApplicationRecord
  has_one_attached :image
  
  validates :image, presence: true
  
  def has_defects?
    result.present? && result['detections'].present? && result['detections'].any?
  end
  
  def defects_by_class
    return {} unless has_defects?
    
    result['detections'].group_by { |d| d['class_name'] }.transform_values(&:count)
  end
  
  def annotated_image_data
    return nil unless result.present? && result['annotated_image'].present?
    
    "data:image/jpeg;base64,#{result['annotated_image']}"
  end
end 