class ChampionsController < ApplicationController

  def index
  end
  
  def show
    current_version = get_version  # from application_contoller.rb
    
    champ_name_id = params[:id]
    
    # nor currently necessary. Needed only if database stores valus (i.e. if website doesn't stay dynamic).
    @champion = Champion.find_by_champ_name_id(champ_name_id)
    
    @champion.retrieve(champ_name_id, current_version)
  end
end
