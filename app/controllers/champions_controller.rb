class ChampionsController < ApplicationController
  
  def index
  end
  
  def show
    champ_name = params[:id]
    @champion = Champion.find_by_champ_name_id(champ_name)  # nor currently necessary. Needed only if database stores valus (i.e. if website doesn't stay dynamic).
    @champion.retrieve(champ_name)
  end
end
