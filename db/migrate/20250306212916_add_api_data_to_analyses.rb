class AddApiDataToAnalyses < ActiveRecord::Migration[7.1]
  def change
    add_column :analyses, :api_data, :jsonb
  end
end
