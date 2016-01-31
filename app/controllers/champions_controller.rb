class ChampionsController < ApplicationController
  before_action :get_version  # from application_contoller.rb
  
  def index
    # Obtain current champions
    url = "http://ddragon.leagueoflegends.com/cdn/#{@current_version}/data/en_US/champion.json"
    response = HTTParty.get(url)
    data = response.parsed_response
    
    # If the game version has updated, update all champions' stats.
    if Champion.first.version != @current_version
      data['data'].each do |champ, info|
        @champ_name_id = info['id']
        
        # If the champion does not exist in the database, add it.
        if Champion.find_by(champ_name_id: @champ_name_id).nil?
          champ_name_id = info['id']  # name ID: Zed -- Khazix --- MasterYi --- # Redundant, left for clarity.
          champ_key = info['key']     #      ID: 238 -- 121 ------ 11 ---------
          name = info['name']         #    name: Zed -- Kha'Zix -- Master Yi --
          
          Champion.create(champ_name_id: champ_name_id,
                          champ_key: champ_key,
                          name: name)
        end
        
        champion = Champion.find_by(champ_name_id: @champ_name_id)
        # Initialize the hashes to store stats.
        champion.initialize_stats
        # Get the parsed Champion JSON file.
        champion.get_data_set(@champ_name_id, @current_version)
        # Get the champion's general stats.
        champion.get_stats
        # Update the champions general stats and version #.
        champion.update(attack: champion.stat_summary[:attack],
                        defense: champion.stat_summary[:defense],
                        magic: champion.stat_summary[:magic],
                        difficulty: champion.stat_summary[:difficulty],
                        version: @current_version)
      end # End iteration through each champion.
    end # End of the version-checking conditional.
  end
  
  def show
    champ_name_id = params[:id]
    
    # Not exactly necessary because all data is loaded dynamically from Riot's
    # API and not from the database.
    # @champion = Champion.find_by_champ_name_id(champ_name_id)
    
    @champion = Champion.new
    
    @champion.retrieve(champ_name_id, @current_version)
  end
end
