class DefectDetectionsController < ApplicationController
  def show
    @defect_detection = DefectDetection.find(params[:id])
  end

  def new
    @defect_detection = DefectDetection.new
  end

  def create
    @defect_detection = DefectDetection.new(defect_detection_params)

    if params[:defect_detection][:image].blank?
      flash.now[:alert] = t('.select_image')
      return render :new, status: :unprocessable_entity
    end

    process_defect_detection
  end

  private

  def defect_detection_params
    params.require(:defect_detection).permit(:image)
  end

  def process_defect_detection
    detection_result = WaferDefectDetector.detect(
      params[:defect_detection][:image],
      params[:confidence].presence || 0.25
    )

    @defect_detection.result = detection_result

    if @defect_detection.save
      redirect_to @defect_detection, notice: t('.success')
    else
      render :new, status: :unprocessable_entity
    end
  rescue StandardError => e
    flash.now[:alert] = "Erreur lors de l'analyse: #{e.message}"
    render :new, status: :unprocessable_entity
  end
end
