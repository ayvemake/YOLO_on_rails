class AddDefectTypeToAnalysisResults < ActiveRecord::Migration[7.1]
  def change
    add_column :analysis_results, :defect_type, :string
  end
end
