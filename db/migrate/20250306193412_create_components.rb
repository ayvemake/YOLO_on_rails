class CreateComponents < ActiveRecord::Migration[7.1]
  def change
    create_table :components do |t|
      t.string :name
      t.text :description
      t.string :reference_image

      t.timestamps
    end
  end
end
