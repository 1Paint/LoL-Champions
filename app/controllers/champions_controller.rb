class ChampionsController < ApplicationController
  
  def index
  end
  
  def show
    champ_name = params[:id]
    @champion = Champion.find_by_name(champ_name)
    @champion.retrieve(champ_name)
  end
end
