class AddRawDataToAnalysisResults < ActiveRecord::Migration[7.1]
  def change
    add_column :analysis_results, :raw_data, :jsonb, default: {}
  end
end 