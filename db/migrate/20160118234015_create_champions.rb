class CreateChampions < ActiveRecord::Migration
  def change
    create_table :champions do |t|
      t.string :champ_name_id
      t.string :champ_key
      t.string :name

      t.timestamps null: false
    end
  end
end
