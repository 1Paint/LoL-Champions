class StaticsController < ApplicationController
  before_action :set_current_version  # from application_contoller.rb
  
  def home
    @roles_hash = Hash.new { |h, k| h[k] = [] }
    
    url = "http://ddragon.leagueoflegends.com/cdn/#{@current_version}/data/en_US/champion.json"
    response = HTTParty.get(url)
    champions = response.parsed_response

    # Store all champion name IDs and names---used to generate images and links.
    champions['data'].each do |champ, info|
      champ_name = info['name'] # Champion name, e.g. Kha'Zix, Master Yi
      champ_name_id = info['id'] # Champion name ID, e.g. KhaZix, MasterYi
      primary_role = info['tags'][0] # e.g. "Fighter", "Mage"
      
      # Store champions in their respective roles---used to enable filtering.
      @roles_hash[:All] << [champ_name, champ_name_id]
      @roles_hash["#{primary_role}".to_sym] << [champ_name, champ_name_id]
    end
    
    # Sort champions by name.
    @roles_hash.each do |role, champ_list|
      @roles_hash[role] = champ_list.sort
    end
  end
  
  def contact
  end
  
  def missingdata
    check_version # From applications controller.
  end
  
  def singlespell
    @button = params[:button]
    @button_num = params[:button_num]
    @version = params[:version]
    @champ_name_id = params[:champ_name_id]
    
    @champion = Champion.find_by(champ_name_id: @champ_name_id)
    @champion.get_data_set(@champ_name_id, @version)
    @champion.initialize_spells
    @champion.get_spell(@champ_name_id, @button.to_sym, @button_num.to_i)
    @spell_button = @button # to render partial champions/spell
    
    respond_to do |format|
      format.html
      format.js { render 'singlespell' }
    end
  end
end
