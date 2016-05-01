class AddMissingDataToChampions < ActiveRecord::Migration
  def change
    add_column :champions, :missing_q, :string
    add_column :champions, :missing_w, :string
    add_column :champions, :missing_e, :string
    add_column :champions, :missing_r, :string
  end
end
