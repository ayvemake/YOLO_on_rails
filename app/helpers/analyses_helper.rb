module AnalysesHelper
  def analysis_status_color(status)
    case status
    when 'completed'
      'bg-green-100 text-green-800'
    when 'processing'
      'bg-blue-100 text-blue-800'
    when 'pending'
      'bg-yellow-100 text-yellow-800'
    when 'failed'
      'bg-red-100 text-red-800'
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
      value.is_a?(String) ? value : Time.at(value.to_i).strftime("%d/%m/%Y %H:%M")
    else
      value.is_a?(Array) ? value.join(", ") : value.to_s
    end
  end
end 