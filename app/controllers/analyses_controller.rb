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
    @analysis.status = :pending
    
    if @analysis.save
      begin
        # Envoyer l'image à l'API FastAPI en arrière-plan
        AnalysisJob.perform_later(@analysis)
        redirect_to @analysis, notice: 'Analyse démarrée. Les résultats se mettront à jour en temps réel.'
      rescue => e
        Rails.logger.error("Erreur lors du lancement de l'analyse: #{e.message}")
        @analysis.update(status: :failed)
        redirect_to @analysis, alert: "Erreur lors du lancement de l'analyse. Veuillez réessayer."
      end
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