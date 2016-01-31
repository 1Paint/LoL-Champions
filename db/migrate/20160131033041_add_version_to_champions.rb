class AddVersionToChampions < ActiveRecord::Migration
  def change
    add_column :champions, :version, :string
  end
end
