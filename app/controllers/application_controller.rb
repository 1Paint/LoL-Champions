class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  def get_versions
    url = "https://ddragon.leagueoflegends.com/api/versions.json"
    response = HTTParty.get(url)
    data = response.parsed_response
    return data
  end
  
  def set_current_version
    @current_version = get_versions[0]
  end
  
  def get_champs(current_version)
    # Obtain current champions.
    url = "http://ddragon.leagueoflegends.com/cdn/#{@current_version}/data/en_US/champion.json"
    response = HTTParty.get(url)
    return response.parsed_response
  end
  
  # Check that we have the current Leauge of Legends API version.
  def check_version
    set_current_version # make @current_version usable.

    # If the version has changed, update all champions and their stats.
    if Champion.first.version != @current_version
      update_version
    end
  end
  
  # Update champion database.
  def update_version
    @champs_list = get_champs(@current_version)
    
    # Update all champions' stats.
    @champs_list['data'].each do |champ, info|
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
      # Get the champion's primary and secondary roles.
      champion.get_roles(@champ_name_id)
      
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
      
      # Find and update missing data for champion's abilities.
      champion.get_missing_data(@current_version, @champ_name_id)
      missing_data_json = {}
      # missing_data_temp has the form [[2, "e1", "f2"], nil, [1, "f4"], nil].
      missing_data_temp = champion.missing_data_temp
      
      buttons = { q: 0, w: 1, e: 2, r: 3 }
      buttons.each do |button, num|
        missing_data_json[button] = {num_missing: nil, missing_vars: []}
        if !missing_data_temp[num].nil?
          missing_data_json[button][:num_missing] = missing_data_temp[num][0]
          missing_data_temp[num][1..-1].each do |variable|
            missing_data_json[button][:missing_vars] << variable
          end
        end
      end
      champion.update(missing_data: missing_data_json)
      
      # Find if the champion has a bad passive description.
      url = "http://ddragon.leagueoflegends.com/cdn/#{@current_version}/data/en_US/champion/#{@champ_name_id}.json"
      response = HTTParty.get(url)
      champ_data = response.parsed_response
      
      champion.get_passive_info(champ_data, @champ_name_id, @current_version)
      if champion.passive_description == "BadDesc"
        champion.update(bad_passive: true)
      else
        champion.update(bad_passive: false)
      end
    end # End iteration through each champion.
  end # Finish updating.
end
