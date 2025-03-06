class AnalysesController < ApplicationController
  before_action :set_analysis, only: [:show]
  
  def index
    @analyses = Analysis.order(created_at: :desc).page(params[:page]).per(20)
  end
  
  def show
    # L'analyse est déjà chargée par le before_action
    respond_to do |format|
      format.html
      format.json { render json: @analysis.summary }
    end
  end
  
  def new
    @analysis = Analysis.new
  end
  
  def create
    @analysis = Analysis.new(analysis_params)
    @analysis.status = 'pending'
    
    if @analysis.save
      # Envoyer l'image à l'API FastAPI pour analyse
      AnalysisJob.perform_later(@analysis.id)
      redirect_to @analysis, notice: 'Analyse en cours de traitement.'
    else
      render :new
    end
  end
  
  private
  
  def set_analysis
    @analysis = Analysis.find(params[:id])
  end
  
  def analysis_params
    params.require(:analysis).permit(:image)
  end
end 