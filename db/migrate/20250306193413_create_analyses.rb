class CreateAnalyses < ActiveRecord::Migration[7.1]
  def change
    create_table :analyses do |t|
      t.string :status
      t.float :score
      t.datetime :timestamp
      t.jsonb :components

      t.timestamps
    end
  end
end
