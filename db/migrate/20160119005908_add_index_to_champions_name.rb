class AddIndexToChampionsName < ActiveRecord::Migration
  def change
    add_index :champions, :champ_name_id
  end
end
