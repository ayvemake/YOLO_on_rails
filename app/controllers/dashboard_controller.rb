class DashboardController < ApplicationController
  def index
    @latest_metrics = Analysis.successful.last&.api_data
    @analyses = Analysis.order(created_at: :desc).limit(5)
    @recent_analyses = Analysis.order(created_at: :desc).limit(10)
    @success_rate = calculate_success_rate
  end

  private

  def calculate_conforming_rate
    total = Analysis.where(status: 'completed').count
    return 0 if total.zero?

    conforming = Analysis.where(status: 'completed').count(&:conforming?)
    (conforming.to_f / total) * 100
  end

  def calculate_success_rate
    completed_analyses = Analysis.completed
    return 0 if completed_analyses.empty?

    successful_analyses = completed_analyses.select do |analysis|
      score = analysis.score
      score.present? && score >= 0.5
    end

    (successful_analyses.count.to_f / completed_analyses.count * 100)
  end
end
