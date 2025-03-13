class CreateInitialSchema < ActiveRecord::Migration[7.1]
  def change
    # Création de la table analyses
    create_table :analyses do |t|
      t.jsonb :api_data
      t.string :error_message
      t.datetime :processed_at
      t.integer :status, default: 0  # Ajout de la colonne status pour l'enum
      
      t.timestamps
    end

    # Création de la table analysis_results
    create_table :analysis_results do |t|
      t.references :analysis, null: false, foreign_key: true
      t.string :defect_class
      t.float :confidence
      t.float :position_x
      t.float :position_y
      t.float :conformity_score
      t.float :rotation
      t.integer :status, default: 0
      t.jsonb :raw_data
      
      t.timestamps
    end

    # Création de la table defect_detections
    create_table :defect_detections do |t|
      t.references :analysis_result, null: false, foreign_key: true
      
      t.timestamps
    end
  end
end 