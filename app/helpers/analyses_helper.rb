module AnalysesHelper
  def analysis_status_color(status)
    case status
    when :completed
      'bg-green-100 text-green-800'
    when :processing
      'bg-blue-100 text-blue-800'
    when :failed
      'bg-red-100 text-red-800'
    when :pending
      'bg-yellow-100 text-yellow-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end

  def format_api_data_value(key, value)
    case key
    when /time/i
      "#{value} ms"
    when /score|confidence|precision|recall|map/i
      number_to_percentage(value * 100, precision: 1)
    when /count|size|number/i
      number_with_delimiter(value)
    when /date/i
      value.is_a?(String) ? value : Time.zone.at(value.to_i).strftime('%d/%m/%Y %H:%M')
    else
      value.is_a?(Array) ? value.join(', ') : value.to_s
    end
  end

  def detection_count(analysis)
    return 0 if analysis.api_data.blank?

    result = analysis.api_data['result']
    return 0 if result.blank?

    detections = result['detections']
    detections.present? ? detections.size : 0
  end

  def score_color(score)
    return 'text-gray-400' if score.nil?

    score >= 0.5 ? 'text-green-600' : 'text-red-600'
  end

  def defect_types(analysis)
    return content_tag(:span, '-', class: 'text-gray-400') if analysis.api_data.blank?

    detections = extract_detections(analysis.api_data)
    render_defect_types(detections)
  end

  private

  def extract_detections(api_data)
    if api_data['result'].present? && api_data['result']['detections'].present?
      api_data['result']['detections']
    elsif api_data['detections'].present?
      api_data['detections']
    else
      []
    end
  end

  def render_defect_types(detections)
    return content_tag(:span, 'Aucun défaut', class: 'text-green-600') unless detections.any?

    defect_types = detections.filter_map { |d| d['class_name'] || d['class'] || d['type'] }.uniq
    if defect_types.any?
      css_class = defect_types.include?('PARTICLE') ? 'text-red-600' : 'text-gray-600'
      content_tag(:span, defect_types.join(', '), class: css_class)
    else
      content_tag(:span, 'Aucun défaut', class: 'text-green-600')
    end
  end
end
