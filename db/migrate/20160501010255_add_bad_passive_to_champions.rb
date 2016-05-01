class AddBadPassiveToChampions < ActiveRecord::Migration
  def change
    add_column :champions, :bad_passive, :boolean
  end
end
