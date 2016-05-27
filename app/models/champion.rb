class Champion < ActiveRecord::Base
  
  attr_accessor :champ_name, :champ_img_url, :title, :lore, :current_version,
                :stat_summary, :stat, :stat_range, :resource,
                :passive, :passive_img_url, :passive_description,
                :spell_name, :spell_img_name, :spell_img_url, 
                :spell_cooldown, :spell_cost, :spell_range, :spell_description,
                :missing_data_temp, :unused_vars_temp, :primary_role, :secondary_role
  
  def initialize_spells
    @spell_name = Hash.new
    @spell_img_name = Hash.new
    @spell_img_url = Hash.new
    @spell_cooldown = Hash.new
    @spell_cost = Hash.new
    @spell_range = Hash.new
    @spell_description = Hash.new
  end
  
  def initialize_stats
    @stat_summary = Hash.new
    @stat = Hash.new
    @stat_max = Hash.new  # Stats at level 18.
    @stat_range = Hash.new  # Stat names, base and max values.
  end
  
  # Get the champion JSON file and parse it.
  def get_data_set(champ_name_id, current_version)
    @current_version = current_version
    @champ_name_id = champ_name_id
    
    url = "http://ddragon.leagueoflegends.com/cdn/#{@current_version}/data/en_US/champion/#{@champ_name_id}.json"
    response = HTTParty.get(url)
    @data = response.parsed_response
  end
  
  # Retrieve champion info, making attributes available to the controller/view.
  def retrieve(champ_name_id, current_version)
    # Create empty hashes to store spells' details.
    initialize_spells
    
    # Create empty hashes to store champion stats (HP, attack, defense, etc).
    initialize_stats
    
    # Get the champion JSON file and parse it. Available as @data.
    get_data_set(champ_name_id, current_version)
    
    # Champion info.
    @champ_name = @data['data'][@champ_name_id]['name']
    @champ_img_url = "http://ddragon.leagueoflegends.com/cdn/img/champion/loading/#{@champ_name_id}_0.jpg"
    @title = @data['data'][@champ_name_id]['title']
    @lore = @data['data'][@champ_name_id]['lore']
    
    # Retrieve champion stats.
    get_stats(champ_name_id)
    
    # Retrieve champion stats at levels 1 and 18.
    get_stats_ranges(champ_name_id)
    
    # Passive info.
    get_passive_info(@data, champ_name_id, current_version)
    
    # Retrieve spells info. Parameters: (Keys Q,W,E,R corresponding to 0,1,2,3) 
    get_spell(champ_name_id, :q, 0)
    get_spell(champ_name_id, :w, 1)
    get_spell(champ_name_id, :e, 2)
    get_spell(champ_name_id, :r, 3)
  end
  
  # Get champion passive ability information.
  # 'data' is the champion JSON file.
  def get_passive_info(data, champ_name_id, current_version)
    @passive = data['data'][champ_name_id]['passive']['name']
    passive_img_name = data['data'][champ_name_id]['passive']['image']['full']
    @passive_img_url = "http://ddragon.leagueoflegends.com/cdn/#{current_version}/img/passive/#{passive_img_name}"
    puts @passive_img_url
    @passive_description = data['data'][champ_name_id]['passive']['description']
    
    if @passive_description.nil?
      @passive_description = "None"
    end
  end
  
  # Retrieve champion stats such as HP, attack, defense, etc.
  def get_stats(champ_name_id)
    # attack, magic, defense, difficulty.
    @data['data'][champ_name_id]['info'].each do |stat_name, value|
      @stat_summary[:"#{stat_name}"] = value
    end
    
    # hp, hpperlevel, mp, mpperlevel, movespeed, armor, armorperlevel,
    # spellblock, spellblockperlevel, attackrange, hpregen, hpregenperlevel,
    # mpregen, mpregenperlevel, crit, critperlevel, attackdamage,
    # attackdamageperlevel, attackspeedoffset, attackspeedperlevel.
    @data['data'][champ_name_id]['stats'].each do |stat_name, value|
      @stat[:"#{stat_name}"] = value
    end
  end
  
  # Using champion base stats and stat growth per level, calculate ranges.
  def get_stats_ranges(champ_name_id)
    @stat_max[:hp] = @stat[:hp] + (17 * @stat[:hpperlevel])
    @stat_max[:mp] = @stat[:mp] + (17 * @stat[:mpperlevel])
    @stat_max[:armor] = @stat[:armor] + (17 * @stat[:armorperlevel])
    @stat_max[:spellblock] = @stat[:spellblock] + (17 * @stat[:spellblockperlevel])
    @stat_max[:hpregen] = @stat[:hpregen] + (17 * @stat[:hpregenperlevel])
    @stat_max[:mpregen] = @stat[:mpregen] + (17 * @stat[:mpregenperlevel])
    @stat_max[:attackdamage] = @stat[:attackdamage] + (17 * @stat[:attackdamageperlevel])
    
    # Attack speed calculated with knowledge from in-game testing and http://leagueoflegends.wikia.com.
    base_attack_speed = 0.625 / (1 + @stat[:attackspeedoffset])
    @stat_max[:attackspeed] = base_attack_speed * (1 + (17 * @stat[:attackspeedperlevel]/100))
    
    # Obtain the resource of the champion.
    @resource = @data['data'][champ_name_id]['partype']
    if @resource == "MP"
      @resource = "Mana"
    end
    
    # Appears on champion page in order shown.
    @stat_range = { hp: { name: "Health",
                          min: @stat[:hp].round(1),
                          max: @stat_max[:hp].round(1) },
               hpregen: { name: "Health Regen",
                          min: @stat[:hpregen].round(1),
                          max: @stat_max[:hpregen].round(1) },
                    mp: { name: "#{@resource}",
                          min: @stat[:mp].round(1),
                          max: @stat_max[:mp].round(1) },
               mpregen: { name: "#{@resource} Regen",
                          min: @stat[:mpregen].round(1),
                          max: @stat_max[:mpregen].round(1) },
             movespeed: { name: "Movement Speed",
                          min: @stat[:movespeed].round(0),
                          max: @stat[:movespeed].round(0) },
                 armor: { name: "Armor",
                          min: @stat[:armor].round(1),
                          max: @stat_max[:armor].round(1) },
            spellblock: { name: "Magic Resist",
                          min: @stat[:spellblock].round(1),
                          max: @stat_max[:spellblock].round(1) },
          attackdamage: { name: "Attack Damage",
                          min: @stat[:attackdamage].round(1),
                          max: @stat_max[:attackdamage].round(1) },
           attackspeed: { name: "Attack Speed",
                          min: base_attack_speed.round(3),
                          max: @stat_max[:attackspeed].round(3) },
           attackrange: { name: "Attack Range",
                          min: @stat[:attackrange].round(0),
                          max: @stat[:attackrange].round(0) } }
    
    # List champion resource if Mana-less or Energy-less.
    # All champion resources used in the game can be found by running lib/scripts/get_champ_resources.rb
    if @resource != "Mana" && @resource != "MP" && @resource != "Energy"
      @stat_range.delete(:mpregen)
      
      if @resource == "None"
        @stat_range.delete(:mp)
      else
        @stat_range[:mp][:name] = "Resource"
        @stat_range[:mp][:min] = @resource
        @stat_range[:mp][:max] = @resource
      end
    end
  end
  
  # Retrieve spell name, image, and description.
  def get_spell(champ_name_id, button, num)
    @spell_name[button] = @data['data'][champ_name_id]['spells'][num]['name']
    @spell_img_name[button] = @data['data'][champ_name_id]['spells'][num]['id']
    @spell_img_url[button] = "http://ddragon.leagueoflegends.com/cdn/#{@current_version}/img/spell/#{@spell_img_name[button]}.png"
    @spell_range[button] = @data['data'][champ_name_id]['spells'][num]['rangeBurn']
    
    input_spell_values(button, num)
    
    # If the spell has two forms, get the other form (e.g. Elise and Nidalee).
    if !@data['data'][champ_name_id]['spells'][num+4].nil?
      @spell_name["#{button}2".to_sym] = @data['data'][champ_name_id]['spells'][num+4]['name']
      @spell_img_name["#{button}2".to_sym] = @data['data'][champ_name_id]['spells'][num+4]['id']
      @spell_img_url["#{button}2".to_sym] = "http://ddragon.leagueoflegends.com/cdn/#{@current_version}/img/spell/#{@spell_img_name["#{button}2".to_sym]}.png"
      @spell_range["#{button}2".to_sym] = @data['data'][champ_name_id]['spells'][num+4]['rangeBurn']
      
      input_spell_values("#{button}2".to_sym, num+4)
    end
  end
  
  # Replace all {{ xX }} strings in spell details with actual values.
  def input_spell_values(button, num)
    # Storage of spell values. Default "**Missing..." value for non-existing
    # keys.
    @spell_values = Hash.new{|_,k| "**Missing/Misplaced API Data** #{k}"}
    
    # Array of base values (e.g. effectBurn = [null, "200", "10/20/30"]).
    # effectBurn[X] (a string such as "1/2/3/4/5") replaces "{{ eX }}" in spell descriptions.
    effectBurn = @data['data'][@champ_name_id]['spells'][num]['effectBurn']

    # Store eX values with their corresponding damage values (e.g. e1: "20/40/60/80/100").
    for i in 0..(effectBurn.length-1)
      if effectBurn[i] != nil
        @spell_values["{{ e#{i} }}"] = effectBurn[i]
      end
    end
    
    # Array of hashes.
    # Hashes store values such as { "link" => "spelldamage",
    #                               "coeff" => 0.6,
    #                               "key" => a1 }
    # Using that example, we have a spelldamage ratio of 0.6. So, we replace
    # "{{ a1 }}" with "0.6 ability power".
    vars = @data['data'][@champ_name_id]['spells'][num]['vars']
    
    # Store aX and fX values with corresponding values.
    # e.g. a1: "12/24/36/48/60".
    vars.each do |hash|          # static        | dynamic
      key = hash['key']          # "aX"          | "aX"
      coeff = hash['coeff']      # 0.2           | [0.2, 0.4, 0.6]
      value_type = hash['link']  # "spelldamage" | "@dynamic.attackdamage"
      
      if coeff.is_a? Float
        coeff = [coeff]
      end
      coeff = coeff.join("/")  # [1, 2, 3] --> "1/2/3"
      
      # Replace JSON value type names with proper English.
      # All value types (spell resources) and their frequencies can be found by
      # running 'lib/scripts/get_all_vars_types.rb'. The following conditionals
      # check the most frequent normal value types first, followed by special
      # value types. Frequencies shown to the right of conditionals.
      if value_type == "spelldamage"  # 374
        value_type = "AP"
        
      elsif value_type == "bonusattackdamage"  # 90
        value_type = "bonus AD"
        
      elsif value_type == "attackdamage"  # 47
        value_type = "AD"
        
      elsif value_type == "armor"  # 5
        value_type = "Armor"
        
      elsif value_type == "bonushealth"  # 5
        value_type = "bonus HP"
        
      elsif value_type == "health"  # 3
        value_type = "HP"
        
      elsif value_type == "bonusarmor"  # 1
        value_type = "bonus Armor"
        
      elsif value_type == "bonusspellblock"  # 1 
        value_type = "bonus Magic Resist"
      end
      
      # Sanitize value types beginning with "@".
      fix_special_value_types(hash)
      
      # If spell value doesn't already exist, input it into the spell_values
      # hash. Conditional needed because spell values already exist for bug 
      # fixes. 
      if @spell_values["{{ #{key} }}"][0..1] == "**"  # **Missing/Misplaced API Data** --- default value indicating nonexistence.
        @spell_values["{{ #{key} }}"] = "#{coeff} #{value_type}"
      end
    end
    
    # Find the costs and resources used for the spell.
    # e.g. cost = "10/20/30/40/50"
    # e.g. resource = "{{ cost }} Mana", "{{ e2 }} Focus"
    # e.g. cost_type = "Mana", "Focus"
    cost = @data['data'][@champ_name_id]['spells'][num]['costBurn']
    resource = @data['data'][@champ_name_id]['spells'][num]['resource']
    cost_type = @data['data'][@champ_name_id]['spells'][num]['costType']
    
    # Substitute spell cost and resource values into spell costs,
    # replacing all "{{ eX }}" and similar.
    @spell_cost[button] = resource
    @spell_cost[button] = @spell_cost[button].gsub("{{ cost }}", cost)
    @spell_cost[button] = @spell_cost[button].gsub(/{{(.*?)}}/, @spell_values)
    
    @spell_cooldown[button] = @data['data'][@champ_name_id]['spells'][num]['cooldownBurn']
    
    # Description for spell, which includes base damage numbers and damage
    # scaling (e.g. +60% bonus AD).
    @spell_description[button] = @data['data'][@champ_name_id]['spells'][num]['tooltip']
    
    # Substitute spell values into spell descriptions, replacing all "{{ eX }}"
    # and similar.
    @spell_description[button] = @spell_description[button].gsub("{{ cost }}", cost)
    @spell_description[button] = @spell_description[button].gsub(/{{(.*?)}}/, @spell_values)
    
    # Versions 0.XXX do not have variables in resource text.
    if @current_version[0] == "0"
      if cost == "0"
        @spell_cost[button] = cost_type
      else
        @spell_cost[button] = cost+" "+cost_type
      end
    end
  end
  
  # Manually fix bugs & typos in Riot's API (wrong/redundant/unclear spell
  # values). All value types here begin with "@".
  def fix_special_value_types(hash)
    key = hash['key']
    coeff = hash['coeff']
    value_type = hash['link']
    
    # Turn single digit into an array of length 1.
    if coeff.is_a? Float
      coeff = [coeff]
    end
    coeff = coeff.join("/")  # [1, 2, 3] --> "1/2/3"
    
    if value_type == "@text"  # 9
      value_type = ""
      @spell_values["{{ #{key} }}"] = "#{coeff} #{value_type}"
    elsif value_type == "@cooldownchampion"  # 5
      value_type = ""
      @spell_values["{{ #{key} }}"] = "#{coeff} #{value_type}"
      
    elsif value_type[0..7] == "@dynamic"
      if value_type == "@dynamic.abilitypower"  # 4
        value_type = "AP"
      elsif value_type == "@dynamic.attackdamage"  # 2
        value_type = "AD"  
      end
      
      #---------------------------------------#
      #             Rengar Bug-fix            #
      #---------------------------------------#
      # Bug: coeff for 'Q' is not in an array.

      # (+/-) indicating scaling direction.
      dyn = hash['dyn']
      # Text description lacks parentheses so must make separate string.
      @spell_values["{{ #{key} }}"] = "(#{dyn}#{coeff} #{value_type})"
      
    #---------------------------------------#
    #             Braum Bug-fix             #
    #---------------------------------------#
    # Bug: Keys f3 and f4 for 'W' have coeffs of 0.
    elsif value_type == "@special.BraumWArmor" || value_type == "@special.BraumWMR"  # 2
      @spell_values["{{ #{key} }}"] = ""

    #---------------------------------------#
    #             Darius Bug-fix            #
    #---------------------------------------#
    # Bug: Maximum damage f3 for 'R' shows as an array of base damages instead
    # of twice the (base + bonus) damage.
    elsif value_type == "@special.dariusr3"  # 1
      # "100/200/300 (+0.75 bonus AD)" x2
      @spell_values["{{ #{key} }}"] = 'Twice the normal damage.'

    #---------------------------------------#
    #               Jax Bug-fix             #
    #---------------------------------------#
    # Bug: Extraneous & incorrect scaling values for increased armor and magic
    # resist in 'R' description.
    elsif value_type == "@special.jaxrarmor" || value_type == "@special.jaxrmr"  # 2
      @spell_values["{{ #{key} }}"] = ""
    
    #---------------------------------------#
    #          Nautilus Bug-fix             #
    #---------------------------------------#
    # Bug: Redundant info in 'Q'. Displays "(0.5 @special.nautilusq)" after
    # stating a 50% cooldown reduction when hitting terrain.
    elsif value_type == "@special.nautilusq"
      @spell_values["{{ #{key} }}"] = ""  # 1

    #---------------------------------------#
    #              Vi  Bug-fix              #
    #---------------------------------------#
    # Bug: Additional damage for 'W' shows up as "+35" instead of "+1% per 35
    # bonus attack damage". Must reformat how this information is displayed
    # because the '%' sign is static in the text, placed after the spell value:
    # "[(Bonus Attack Damage)x(1/35)]".
    elsif value_type == "@special.viw"  # 1
      @spell_values["{{ #{key} }}"] = "[(bonus AD)x(1/35)]"
    
    #---------------------------------------#
    #      Stacks (Nasus, Veigar, etc.)     #
    #---------------------------------------#
    # "@stacks" --> "Number of Stacks"
    elsif value_type == "@stacks"  # 2
      @spell_values["{{ #{key} }}"] = "Number of Stacks"
    end
  end
  
  # Get the number of missing data for abilities of a given champion.
  def get_missing_data(current_version, champ_name_id)
    @current_version = current_version
    @champ_name_id = champ_name_id
    
    initialize_spells
    
    # Storage of missing data. Will end up looking like:
    # [[2, "e1", "f2"], nil, [1, "f4"], nil].
    # This indicates that for the champion in question, there are 2 missing
    # values for Q (e1 and f2), none for W, 1 for E (f4), and none for R.
    @missing_data_temp = []

    @buttons = { q: 0, w: 1, e: 2, r: 3 }
    
    # Get champion data.
    url = "http://ddragon.leagueoflegends.com/cdn/#{@current_version}/data/en_US/champion/#{@champ_name_id}.json"
    response = HTTParty.get(url)
    @data = response.parsed_response
    
    # Get missing data for each ability.
    @buttons.each do |button, num|
      # Get spell name, image, description.
      get_spell(@champ_name_id, button, num)
       
      # Get number of missing values.
      num_missing_data = @spell_description[button].scan("**Missing/Misplaced API Data**").count
      num_missing_data += @spell_cost[button].scan("**Missing/Misplaced API Data**").count
      
      # Missing variables stored as e.g. [["e1"], ["f3"], ["f1"]].
      missing_vars_description = @spell_description[button].scan(/{{\s(.*?)\s}}/)
      missing_vars_cost = @spell_cost[button].scan(/{{\s(.*?)\s}}/)
      
      # For champions with secondary spells.
      if !@data['data'][@champ_name_id]['spells'][num+4].nil?
        num_missing_data += @spell_description["#{button}2".to_sym].scan("**Missing/Misplaced API Data**").count
        num_missing_data += @spell_cost["#{button}2".to_sym].scan("**Missing/Misplaced API Data**").count
        
        missing_vars_description_2 = @spell_description["#{button}2".to_sym].scan(/{{\s(.*?)\s}}/)
        missing_vars_cost_2 = @spell_cost["#{button}2".to_sym].scan(/{{\s(.*?)\s}}/)
      end
        
      if num_missing_data != 0
        missing_data = [num_missing_data]
        
        # Add primary ability's missing data.
        missing_vars_description.each do |var_in_array| # var_in_array is of the form ["eX"].
          missing_data << var_in_array[0]
        end
        missing_vars_cost.each do |var_in_array|
          missing_data << var_in_array[0] 
        end
        
        # Add secondary ability's missing data if it exists.
        if !missing_vars_description_2.nil? && !missing_vars_description_2.empty?
          missing_vars_description_2.each do |var_in_array| # var_in_array is of the form ["eX"].
            missing_data << var_in_array[0]
          end
        end
        if !missing_vars_cost_2.nil? && !missing_vars_cost_2.empty?
          missing_vars_cost_2.each do |var_in_array|
            missing_data << var_in_array[0] 
          end
        end
        @missing_data_temp << missing_data
      else
        @missing_data_temp << nil
      end
    end
  end

  # Retrieve all unused variables in a champion's abilities.
  def get_unused_vars(current_version, champ_name_id)
    @unused_vars_temp = {q: {}, w: {}, e: {}, r: {}}
    buttons = { q: 0, w: 1, e: 2, r: 3 }
    spell_description = {}
    resource_cost = {}
    vars_requested = {}
    vars_available = {}
    
    # Get champion data.
    url = "http://ddragon.leagueoflegends.com/cdn/#{current_version}/data/en_US/champion/#{champ_name_id}.json"
    response = HTTParty.get(url)
    data = response.parsed_response
    
    buttons.each do |button, num|
      spell_description[button] = data['data'][champ_name_id]['spells'][num]['tooltip']
      resource_cost[button] = data['data'][champ_name_id]['spells'][num]['resource']
      vars_requested[button] = {}
      vars_available[button] = {}
      
      # Obtain all variables present in spell and cost descriptions.
      spell_description[button].scan(/{{\s(.*?)\s}}/).each do |var|
        vars_requested[button][var[0].to_sym] = true
      end
      resource_cost[button].scan(/{{\s(.*?)\s}}/).each do |var|
        vars_requested[button][var[0].to_sym] = true
      end
      
      # Obtain all variables provided/available.
      e_vars = data['data'][champ_name_id]['spells'][num]['effectBurn']
      i = 1
      e_vars[1..-1].each do |values|
        if values == nil
          values = "None"
        end
        vars_available[button]["e#{i}".to_sym] = values
        i += 1
      end
      v_vars = data['data'][champ_name_id]['spells'][num]['vars']
      v_vars.each do |index|
        value = index['coeff']
        if value == nil
          value = "None"
        end
        vars_available[button][index['key'].to_sym] = value
      end
      
      # Variables Available - Variables Requested = Unused Variables
      vars_available[button].each do |var, value|
        if !vars_requested[button].key?(var)
          @unused_vars_temp[button][var.to_sym] = value
        end
      end
    end
  end
  
  # Find and the champion's primary and secondary roles.
  def get_roles(champ_name_id)
    @primary_role = @data['data'][champ_name_id]['tags'][0]
    @secondary_role = @data['data'][champ_name_id]['tags'][1]
  end
end

####################################################
#     Complicated code---inc speed/efficiency?     #
####################################################
# Replace JSON value type names with proper English.
# All value types (spell resources) and their frequencies can be found by
# running 'lib/scripts/get_all_vars_types.rb'. The following conditionals
# check the most frequent normal value types first, followed by special
# value types (dynamic-scaling abiltiies).

# Only check enough letters of the value type name to distinguish from all
# other value types. Should probably write a test for this.

# if value_type[0] == "s"  # --------------- 374 spelldamage
#   value_type = "Ability Power"
# elsif value_type[10] == "k"  # ----------- 90 bonusattackdamage
#   value_type = "Bonus Attack Damage"
# elsif value_type[5] == "k"  # ------------ 47 attackdamage
#   value_type = "Attack Damage"
# elsif value_type[4] == "r"  # ------------ 5 armor
#   value_type = "Armor"
# elsif value_type[5] == "h"  # ------------ 5 bonushealth
#   value_type = "Bonus Health"
# elsif value_type[0] == "h"  # ------------ 3 health
#   value_type = "Health"
# elsif value_type[6] == "r"  # ------------ 1 bonusarmor
#   value_type = "Bonus Armor"
# elsif value_type[5] == "s"   # ----------- 1 bonusspellblock
#   value_type = "Bonus Magic Resist"
# end

# if value_type[3] == "x"  # ---------------------- 9 @text
#   value_type = ""
# elsif value_type[1] == "c"  # ------------------- 5 @cooldownchampion
#   value_type = ""
# elsif value_type[1] == "d"  # dynamic
#   if value_type[16] == "p"  # ------------------- 4 @dynamic.abilitypower
#     value_type = "Ability Power"
#   elsif value_type[14] == "k"  # ---------------- 2 @dynamic.attackdamage
#     value_type = "Attack Damage"
#   end
  
#   #---------------------------------------#
#   #             Rengar Bug-fix            #
#   #---------------------------------------#
#   # Bug: coeff is not in an array.
#   # Turn single digit into an array of length 1.
#   if coeff.is_a? Float
#     coeff = [coeff]
#   end
  
#   # [1, 2, 3] --> "1/2/3"
#   coeff = coeff.join("/")
#   # (+/-) indicating scaling direction.
#   dyn = hash['dyn']
#   # Text description lacks parentheses so must make separate string.
#   @spell_values["{{ #{key} }}"] = "(#{dyn}#{coeff} #{value_type})"
  
# #---------------------------------------#
# #             Braum Bug-fix             #
# #---------------------------------------#
# # Bug: keys f3 and f4 have coeffs of 0.
# elsif value_type[9] == "B" # -------------------- 1, 1 @special.Braum(Armor/MR)
#   @spell_values["{{ #{key} }}"] = ""
