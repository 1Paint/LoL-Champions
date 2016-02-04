require 'httparty'

# Copied from champion.rb in models.
class ChampionTest
  
  # Retrieve spell name, image, and description.
  def get_spell(button, num, champ_name_id)
    @champ_name_id = champ_name_id
    
    url = "http://ddragon.leagueoflegends.com/cdn/6.1.1/data/en_US/champion/#{@champ_name_id}.json"
    response = HTTParty.get(url)
    @data = response.parsed_response

    @spell_cooldown = Hash.new
    @spell_cost = Hash.new
    @spell_range = Hash.new
    @spell_description = Hash.new
    
    # Replace all {{ xX }} strings in spell details with actual values.
    input_spell_values(button, num)
  end
  
  # Replace all {{ xX }} strings in spell details with actual values.
  def input_spell_values(button, num)
    # Storage of damage values.
    @spell_values = Hash.new("*API DATA MISSING*")
    
    # Array of base values (e.g. effectBurn = [null, "200", "10/20/30"]).
    # effectBurn[X] (a string such as "1/2/3/4/5") replaces "{{ eX }}" in spell descriptions.
    effectBurn = @data['data'][@champ_name_id]['spells'][num]['effectBurn']

    # Store eX values with their corresponding damage values (e.g. e1: "20/40/60/80/100").
    for i in 0..(effectBurn.length-1)
      if effectBurn[i] != nil
        @spell_values["{{ e#{i} }}"] = effectBurn[i]
      end
    end
    
    # Array of hashes (e.g. vars = [{a: 3}, {b: 4}, {c: 5}]).
    # Hashes store values such as { "link" => "spelldamage",
    #                               "coeff" => 0.6,
    #                               "key" => a1 }
    # Example: "0.6 ability power" replaces "{{ a1 }}".
    vars = @data['data'][@champ_name_id]['spells'][num]['vars']
    
    # Store aX and fX values with corresponding values (e.g. a1: "12/24/36/48/60").
    vars.each do |hash|          # static        | dynamic
      key = hash['key']          # "aX"          | "aX"
      coeff = hash['coeff']      # 0.2           | [0.2, 0.4, 0.6]
      value_type = hash['link']  # "spelldamage" | "@dynamic.attackdamage"
      
      # Replace JSON value type names with proper English.
      # All value types (spell resources) and their frequencies can be found by
      # running 'test/scripts/get_all_vars_types.rb'. The following conditionals
      # check the most frequent normal value types first, followed by special
      # value types. Frequencies shown to the right of conditionals.
      if value_type == "spelldamage"  # 374
        value_type = "Ability Power"
        
      elsif value_type == "bonusattackdamage"  # 90
        value_type = "Bonus Attack Damage"
        
      elsif value_type == "attackdamage"  # 47
        value_type = "Attack Damage"
        
      elsif value_type == "armor"  # 5
        value_type = "Armor"
        
      elsif value_type == "bonushealth"  # 5
        value_type = "Bonus Health"
        
      elsif value_type == "health"  # 3
        value_type = "Health"
        
      elsif value_type == "bonusarmor"  # 1
        value_type = "Bonus Armor"
        
      elsif value_type == "bonusspellblock"  # 1 
        value_type = "Bonus Magic Resist"
      end
      
      # Sanitize value types beginning with "@".
      fix_special_value_types(hash)
      
      # If spell value doesn't already exist, input it into the spell_values hash. 
      if @spell_values["{{ #{key} }}"] == "*API DATA MISSING*"
        @spell_values["{{ #{key} }}"] = "#{coeff} #{value_type}"
      end
    end
    
    # Description for spell, which includes base damage numbers and damage scaling (e.g. +60% bonus AD).
    @spell_description[button] = @data['data'][@champ_name_id]['spells'][num]['tooltip']
    
    # Substitute spell values into spell descriptions, replacing all "{{ eX }}" and similar.
    @spell_description[button] = @spell_description[button].gsub(/{{(\s[eaf]\d*\s)}}/, @spell_values)
    
    # Empty values showing up as ().
    num_empty_data = @spell_description[button].scan("(*API DATA MISSING*)").count
    
    # Find number of empy data for each champion.
    if num_empty_data != 0
      puts "#{@champ_name_id}: #{button.upcase} has #{num_empty_data} empty set(s) of values"
    end
    
    # Missing values showing up as (+)
    num_missing_data = @spell_description[button].scan("*API DATA MISSING*").count
    
    # Find number of missing data for each champion.
    if num_missing_data != 0
      puts "#{@champ_name_id}: #{button.upcase} is missing #{num_missing_data} set(s) of values"
    end
    
    # Find the costs and resources used for the spell.
    # e.g. cost = "10/20/30/40/50"
    # e.g. resource = "{{ cost }} Mana, {{ e2 }} Focus"
    cost = @data['data'][@champ_name_id]['spells'][num]['costBurn']
    resource = @data['data'][@champ_name_id]['spells'][num]['resource']
    
    # Substitute spell values into spell descriptions, replacing all "{{ eX }}" and similar.
    @spell_cost[button] = resource.gsub(/{{(\s[eaf]\d*\s)}}/, @spell_values)
    @spell_cost[button] = @spell_cost[button].gsub("{{ cost }}", cost)
  end
  
  # Manually fix bugs & typos in Riot's API (wrong/redundant/unclear spell
  # values). All value types here begin with "@".
  def fix_special_value_types(hash)
    key = hash['key']
    coeff = hash['coeff']
    value_type = hash['link']
    
    if value_type == "@text"  # 9
      value_type = ""
    elsif value_type == "@cooldownchampion"  # 5
      value_type = ""
      
    elsif value_type[0..7] == "@dynamic"
      if value_type == "@dynamic.abilitypower"  # 4
        value_type = "Ability Power"
      elsif value_type == "@dynamic.attackdamage"  # 2
        value_type = "Attack Damage"  
      end
      
      #---------------------------------------#
      #             Rengar Bug-fix            #
      #---------------------------------------#
      # Bug: coeff for 'Q' is not in an array.
      # Turn single digit into an array of length 1.
      if coeff.is_a? Float
        coeff = [coeff]
      end
      
      # [1, 2, 3] --> "1/2/3"
      coeff = coeff.join("/")
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
      @spell_values["{{ #{key} }}"] = '200/400/600 (+1.5 Bonus Attack Damage)'

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
      @spell_values["{{ #{key} }}"] = "[(Bonus Attack Damage)x(1/35)]"
    
    #---------------------------------------#
    #      Stacks (Nasus, Veigar, etc.)     #
    #---------------------------------------#
    # "@stacks" --> "Number of Stacks"
    elsif value_type == "@stacks"  # 2
      @spell_values["{{ #{key} }}"] = "Number of Stacks"
    end
  end
end

# Obtain all champions.
url = "http://ddragon.leagueoflegends.com/cdn/6.1.1/data/en_US/champion.json"
response = HTTParty.get(url)
champions = response.parsed_response

# Find which champions have missing API data.
champions['data'].each do |champ, info|   
  champ_name_id = info['id'] 

  champion = ChampionTest.new
  
  champion.get_spell(:q, 0, champ_name_id)
  champion.get_spell(:w, 1, champ_name_id)
  champion.get_spell(:e, 2, champ_name_id)
  champion.get_spell(:r, 3, champ_name_id)
end
