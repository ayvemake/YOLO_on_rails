class MakeComponentIdNullableInAnalysisResults < ActiveRecord::Migration[7.1]
  def change
    change_column_null :analysis_results, :component_id, true
  end
end 