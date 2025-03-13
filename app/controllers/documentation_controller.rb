class DocumentationController < ApplicationController
  def index
    @latest_metrics = Analysis.successful.last&.api_data
    @total_analyses = Analysis.count
    @successful_analyses = Analysis.successful.count
  end
end
