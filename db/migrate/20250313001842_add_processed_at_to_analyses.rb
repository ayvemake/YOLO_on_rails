class AddProcessedAtToAnalyses < ActiveRecord::Migration[7.1]
  def change
    add_column :analyses, :processed_at, :datetime
  end
end
