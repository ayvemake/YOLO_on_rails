class AddProcessingTimeToAnalyses < ActiveRecord::Migration[7.0]
  def change
    add_column :analyses, :processing_time, :float
  end
end 