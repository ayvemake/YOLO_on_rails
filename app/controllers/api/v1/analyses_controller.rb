class Api::V1::AnalysesController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def create
    @analysis = Analysis.find(params[:id])
    
    if @analysis.update(analysis_result_params)
      # Traiter les résultats des composants
      process_components_results(params[:components])
      
      render json: { status: 'success', analysis: @analysis.summary }
    else
      render json: { status: 'error', message: @analysis.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def show
    @analysis = Analysis.find(params[:id])
    render json: { analysis: @analysis.summary, results: @analysis.analysis_results }
  end
  
  private
  
  def analysis_result_params
    params.permit(:status, :score, :timestamp)
  end
  
  def process_components_results(components_data)
    return unless components_data.is_a?(Array)
    
    components_data.each do |comp_data|
      component = Component.find_by(name: comp_data[:name]) || Component.create(name: comp_data[:name])
      
      @analysis.analysis_results.create(
        component: component,
        position_x: comp_data[:position_x],
        position_y: comp_data[:position_y],
        rotation: comp_data[:rotation],
        conformity_score: comp_data[:score],
        status: comp_data[:status]
      )
    end
  end
end 