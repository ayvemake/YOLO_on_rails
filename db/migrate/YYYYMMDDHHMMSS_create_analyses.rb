class CreateAnalyses < ActiveRecord::Migration[7.0]
  def change
    create_table :analyses do |t|
      t.string :status, default: 'pending'
      t.float :score
      t.datetime :timestamp
      t.jsonb :components, default: {}

      t.timestamps
    end
    
    add_index :analyses, :status
  end
end 