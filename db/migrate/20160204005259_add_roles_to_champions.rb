class AddRolesToChampions < ActiveRecord::Migration
  def change
    add_column :champions, :primary, :string
    add_column :champions, :secondary, :string
  end
end
