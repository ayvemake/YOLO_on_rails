class ChangeComponentsToJsonb < ActiveRecord::Migration[7.1]
  def change
    change_column :analyses, :components, :jsonb, using: 'components::jsonb', default: {}
  end
end 