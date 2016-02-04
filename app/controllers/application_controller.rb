class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  # Get the current Leauge of Legends API version.
  def check_version
    url = "https://ddragon.leagueoflegends.com/api/versions.json"
    response = HTTParty.get(url)
    data = response.parsed_response
    @current_version = data[0]

    # If the version has changed, update all champions and their stats.
    if Champion.first.version != @current_version
      update_version
    end
  end
  
  # Update champion database if the version has changed.
  def update_version
    # Obtain current champions
    url = "http://ddragon.leagueoflegends.com/cdn/#{@current_version}/data/en_US/champion.json"
    response = HTTParty.get(url)
    @data = response.parsed_response
    
    # Update all champions' stats.
    @data['data'].each do |champ, info|
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
      # Get the champion's general and detailed stats.
      champion.get_stats(@champ_name_id)
      champion.get_stats_ranges(@champ_name_id)
      # Get the champion's priary and secondary roles.
      champion.get_roles(champion, @data)
      
      # Update the champion's general stats and version #.
      champion.update(attack: champion.stat_summary[:attack],
                      defense: champion.stat_summary[:defense],
                      magic: champion.stat_summary[:magic],
                      difficulty: champion.stat_summary[:difficulty],
                      primary: champion.primary_role,
                      secondary: champion.secondary_role,
                      version: @current_version)
      # Update the champion's detailed stats (stats at levels 1 and 18).
      # These stats include hp, hpregen, mp, mpregen, movespeed, armor, 
      # spellblock, attackdamage, attackspeed, and attackrange.
      champion.stat_range.each do |stat, values|
        champion.update("#{stat}min".to_sym => values[:min],
                        "#{stat}max".to_sym => values[:max])
      end
    end # End iteration through each champion.
  end
end
