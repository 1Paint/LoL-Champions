class AddUnusedVarsToChampions < ActiveRecord::Migration
  def change
    add_column :champions, :unused_vars, :json, default: {}, null: false
  end
end
