class StaticsController < ApplicationController
  before_action :check_version  # from application_contoller.rb
  
  def home
    @roles_hash = Hash.new { |h, k| h[k] = [] }
    
    # Get all champion name IDs and names.
    url = "http://ddragon.leagueoflegends.com/cdn/#{@current_version}/data/en_US/champion.json"
    response = HTTParty.get(url)
    data = response.parsed_response
    
    # Store all champion name IDs and names---used to generate images and links.
    data['data'].each do |champ, info|
      champ_name_id = info['id']  # Champion name ID, e.g. KhaZix, MasterYi
      champ_name = info['name']   # Champion name, e.g. Kha'Zix, Master Yi
      
      @roles_hash[:All] << [champ_name, champ_name_id]
      @roles_hash["#{Champion.find_by(champ_name_id: champ_name_id).primary}".to_sym] << [champ_name, champ_name_id]
      # Sort champions by name.
      @roles_hash.each do |key, array|
        @roles_hash[key] = @roles_hash[key].sort
      end
    end
  end
  
  def contact
  end
  
  def missingdata
    @champion = Champion.new
    @champion.get_missing_data(@current_version)
  end
end
