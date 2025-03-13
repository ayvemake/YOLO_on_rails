class DashboardController < ApplicationController
  def index
    @latest_metrics = Analysis.successful.last&.api_data
    @analyses = Analysis.order(created_at: :desc).limit(5)
    @recent_analyses = Analysis.order(created_at: :desc).limit(10)
    @conforming_rate = calculate_conforming_rate
  end

  private

  def calculate_conforming_rate
    total = Analysis.where(status: 'completed').count
    return 0 if total.zero?

    conforming = Analysis.where(status: 'completed').count(&:conforming?)
    (conforming.to_f / total) * 100
  end
end
