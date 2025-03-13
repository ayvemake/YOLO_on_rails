class AnalysesController < ApplicationController
  before_action :set_analysis, only: [:show]
  
  def index
    @analyses = Analysis.order(created_at: :desc).page(params[:page]).per(10)
  end
  
  def show
    # La vue sera mise à jour via WebSocket
    @websocket_url = AiService.websocket_url
  end
  
  def new
    @analysis = Analysis.new
  end
  
  def create
    @analysis = Analysis.new(analysis_params)
    
    if @analysis.save
      # Enqueue le job avec l'ID de l'analyse, pas l'objet lui-même
      AnalysisJob.perform_later(@analysis.id)
      redirect_to @analysis, notice: 'Analysis was successfully created.'
    else
      render :new
    end
  end
  
  def status
    @analysis = Analysis.find(params[:id])
    render json: {
      id: @analysis.id,
      status: @analysis.status,
      score: @analysis.score,
      has_result_image: @analysis.result_image.try(:attached?),
      result_image_url: @analysis.result_image.try(:attached?) ? url_for(@analysis.result_image) : nil,
      results_count: @analysis.analysis_results.count
    }
  end
  
  private
  
  def set_analysis
    @analysis = Analysis.find(params[:id])
  end
  
  def analysis_params
    params.require(:analysis).permit(:image)
  end
end 