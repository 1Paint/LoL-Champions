class ChampionsController < ApplicationController
  before_action :check_version  # from application_contoller.rb
  
  def index
  end
  
  def show
    champ_name_id = params[:id]
    
    # Not exactly necessary because all data is loaded dynamically from Riot's
    # API and not from the database.
    ### @champion = Champion.find_by_champ_name_id(champ_name_id)
    
    @champion = Champion.new
    
    @champion.retrieve(champ_name_id, @current_version)
  end
end
