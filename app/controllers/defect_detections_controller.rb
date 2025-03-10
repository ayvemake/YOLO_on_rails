class DefectDetectionsController < ApplicationController
  def new
    @defect_detection = DefectDetection.new
  end
  
  def create
    @defect_detection = DefectDetection.new(defect_detection_params)
    
    if params[:defect_detection][:image].present?
      # Appeler le service de détection
      begin
        detection_result = WaferDefectDetector.detect(
          params[:defect_detection][:image],
          params[:confidence].presence || 0.25
        )
        
        @defect_detection.result = detection_result
        
        if @defect_detection.save
          redirect_to @defect_detection, notice: 'Analyse de défauts terminée avec succès.'
        else
          render :new, status: :unprocessable_entity
        end
      rescue => e
        flash.now[:alert] = "Erreur lors de l'analyse: #{e.message}"
        render :new, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "Veuillez sélectionner une image à analyser."
      render :new, status: :unprocessable_entity
    end
  end
  
  def show
    @defect_detection = DefectDetection.find(params[:id])
  end
  
  private
  
  def defect_detection_params
    params.require(:defect_detection).permit(:image)
  end
end 