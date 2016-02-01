class AddDetailedStatsToChampions < ActiveRecord::Migration
  def change
    add_column :champions, :hpmin, :string
    add_column :champions, :hpregenmin, :string
    add_column :champions, :mpmin, :string
    add_column :champions, :mpregenmin, :string
    add_column :champions, :movespeedmin, :string
    add_column :champions, :armormin, :string
    add_column :champions, :spellblockmin, :string
    add_column :champions, :attackdamagemin, :string
    add_column :champions, :attackspeedmin, :string
    add_column :champions, :attackrangemin, :string
    add_column :champions, :hpmax, :string
    add_column :champions, :hpregenmax, :string
    add_column :champions, :mpmax, :string
    add_column :champions, :mpregenmax, :string
    add_column :champions, :movespeedmax, :string
    add_column :champions, :armormax, :string
    add_column :champions, :spellblockmax, :string
    add_column :champions, :attackdamagemax, :string
    add_column :champions, :attackspeedmax, :string
    add_column :champions, :attackrangemax, :string
  end
end
