class CreateAnalysisResults < ActiveRecord::Migration[7.0]
  def change
    create_table :analysis_results do |t|
      t.references :analysis, null: false, foreign_key: true
      t.references :component, null: false, foreign_key: true
      t.float :position_x
      t.float :position_y
      t.float :rotation
      t.float :conformity_score
      t.string :status
      t.jsonb :raw_data, default: {}

      t.timestamps
    end
    
    add_index :analysis_results, :status
  end
end 