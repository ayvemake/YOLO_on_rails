class AddErrorMessageToAnalyses < ActiveRecord::Migration[7.1]
  def change
    add_column :analyses, :error_message, :text
  end
end
