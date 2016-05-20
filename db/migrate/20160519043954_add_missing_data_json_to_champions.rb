class AddMissingDataJsonToChampions < ActiveRecord::Migration
  def change
    add_column :champions, :missing_data, :json, default: {}, null: false
  end
end
