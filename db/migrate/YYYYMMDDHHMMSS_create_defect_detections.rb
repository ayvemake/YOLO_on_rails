class CreateDefectDetections < ActiveRecord::Migration[7.0]
  def change
    create_table :defect_detections do |t|
      t.json :result
      t.timestamps
    end
  end
end 