class RenameComponentsToApiData < ActiveRecord::Migration[7.1]
  def change
    rename_column :analyses, :components, :api_data
  end
end 