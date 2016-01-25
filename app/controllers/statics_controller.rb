class StaticsController < ApplicationController
  before_action :get_version  # from application_contoller.rb
  
  def home
    @champion_list = Hash.new
    
    url = "http://ddragon.leagueoflegends.com/cdn/#{@current_version}/data/en_US/champion.json"
    response = HTTParty.get(url)
    data = response.parsed_response
    
    # Store all champion name IDs and names---used to generate images and links.
    data['data'].each do |champ, info|
      champ_name_id = info['id']  # Champion name ID, e.g. KhaZix, MasterYi
      champ_name = info['name']   # Champion name, e.g. Kha'Zix, Master Yi
      
      @champion_list[:"#{champ_name_id}"] = champ_name
    end
  end
  
  def contact
  end
  
  def missingdata
    @champion = Champion.new
    @champion.get_missing_data(@current_version)
  end
end
