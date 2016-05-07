module ChampionsHelper
  
  def get_champ(champ_name_id, current_version)
    @champion = Champion.new
    @champion.retrieve(champ_name_id, current_version)
  end
  
end
