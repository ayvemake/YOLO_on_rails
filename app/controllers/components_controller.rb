class ComponentsController < ApplicationController
  before_action :set_component, only: [:show, :edit, :update, :destroy]
  
  def index
    @components = Component.includes(:analysis_results)
                          .order(created_at: :desc)
                          .page(params[:page])
  end
  
  def show
    # Le composant est déjà chargé par le before_action
  end
  
  def new
    @component = Component.new
  end
  
  def create
    @component = Component.new(component_params)
    
    if @component.save
      redirect_to @component, notice: 'Composant créé avec succès.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
    # Le composant est déjà chargé par le before_action
  end
  
  def update
    if @component.update(component_params)
      redirect_to @component, notice: 'Composant mis à jour avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @component.destroy
    redirect_to components_path, notice: 'Composant supprimé avec succès.', status: :see_other
  end
  
  private
  
  def set_component
    @component = Component.find(params[:id])
  end
  
  def component_params
    params.require(:component).permit(:name, :description, :reference_image)
  end
end 