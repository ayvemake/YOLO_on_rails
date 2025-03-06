class DashboardController < ApplicationController
  def index
    @recent_analyses = Analysis.order(created_at: :desc).limit(10)
    @components = Component.all
    @conforming_rate = calculate_conforming_rate
  end
  
  private
  
  def calculate_conforming_rate
    total = Analysis.where(status: 'completed').count
    return 0 if total == 0
    
    conforming = Analysis.where(status: 'completed').select { |a| a.conforming? }.count
    (conforming.to_f / total) * 100
  end
end 