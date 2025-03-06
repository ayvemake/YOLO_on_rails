class AddApiDataToAnalyses < ActiveRecord::Migration[7.1]
  def change
    add_column :analyses, :api_data, :jsonb, default: {}
    
    # Copier les données de components vers api_data
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE analyses
          SET api_data = components
          WHERE components IS NOT NULL
        SQL
      end
    end
  end
end 