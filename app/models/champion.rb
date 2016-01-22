class Champion < ActiveRecord::Base
  
  attr_accessor :champ_img_url, :title, :lore,
                :stat_summary, :stat, :stat_range, :resource,
                :passive, :passive_img_url, :passive_description,
                :spell_name, :spell_img_name, :spell_img_url, 
                :spell_cooldown, :spell_cost, :spell_range, :spell_descripion
  
  def initialize_spells
    @spell_name = Hash.new
    @spell_img_name = Hash.new
    @spell_img_url = Hash.new
    @spell_cooldown = Hash.new
    @spell_cost = Hash.new
    @spell_range = Hash.new
    @spell_descripion = Hash.new
  end
  
  def initialize_stats
    @stat_summary = Hash.new
    @stat = Hash.new
    @stat_max = Hash.new  # Stats at level 18.
    @stat_range = Hash.new  # Stat names, base and max values.
  end
  
  # Retrieve champion info, making attributes available to the controller/view.
  def retrieve(champ_name_id, current_version)
    @current_version = current_version
    
    # Create empty hashes to store spells' details.
    initialize_spells
    
    # Create empty hashes to store champion stats (HP, attack, defense, etc).
    initialize_stats
    
    @champ_name_id = champ_name_id
    
    url = "http://ddragon.leagueoflegends.com/cdn/#{@current_version}/data/en_US/champion/#{@champ_name_id}.json"
    response = HTTParty.get(url)
    @data = response.parsed_response
    
    # Champion info.
    @champ_img_url = "http://ddragon.leagueoflegends.com/cdn/img/champion/loading/#{@champ_name_id}_0.jpg"
    @title = @data['data'][@champ_name_id]['title']
    @lore = @data['data'][@champ_name_id]['lore']
    
    # Retrieve champion stats.
    get_stats
    
    # Retrieve champion stats at levels 1 and 18.
    get_stats_ranges
    
    # Passive info.
    @passive = @data['data'][@champ_name_id]['passive']['name']
    passive_img_name = @data['data'][@champ_name_id]['passive']['image']['full']
    @passive_img_url = "http://ddragon.leagueoflegends.com/cdn/#{@current_version}/img/passive/#{passive_img_name}"
    @passive_description = @data['data'][@champ_name_id]['passive']['description']
    
    # Retrieve spells info.
    get_spell(:q, 0)
    get_spell(:w, 1)
    get_spell(:e, 2)
    get_spell(:r, 3)
  end
  
  # Retrieve champion stats such as HP, attack, defense, etc.
  def get_stats
    # attack, magic, defense, difficulty.
    @data['data'][@champ_name_id]['info'].each do |stat_name, value|
      @stat_summary[:"#{stat_name}"] = value
    end
    
    # hp, hpperlevel, mp, mpperlevel, movespeed, armor, armorperlevel,
    # spellblock, spellblockperlevel, attackrange, hpregen, hpregenperlevel,
    # mpregen, mpregenperlevel, crit, critperlevel, attackdamage,
    # attackdamageperlevel, attackspeedoffset, attackspeedperlevel.
    @data['data'][@champ_name_id]['stats'].each do |stat_name, value|
      @stat[:"#{stat_name}"] = value
    end
    
    @resource = @data['data'][@champ_name_id]['partype']
    if @resource == "MP"
      @resource = "Mana"
    end
  end
  
  # Using champion base stats and stat growth per level, calculate ranges.
  def get_stats_ranges
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
                          min: @stat[:movespeed],
                          max: @stat[:movespeed] },
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
                          min: @stat[:attackrange],
                          max: @stat[:attackrange] } }
    
    # List champion resource if Mana-less or Energy-less.
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
  def get_spell(key, num)
    @spell_name[key] = @data['data'][@champ_name_id]['spells'][num]['name']
    @spell_img_name[key] = @data['data'][@champ_name_id]['spells'][num]['id']
    @spell_img_url[key] = "http://ddragon.leagueoflegends.com/cdn/#{@current_version}/img/spell/#{@spell_img_name[key]}.png"
    @spell_cooldown[key] = @data['data'][@champ_name_id]['spells'][num]['cooldownBurn']
    
    # Find the resource used for the spell.
    cost = @data['data'][@champ_name_id]['spells'][num]['costBurn']
    cost_type = @data['data'][@champ_name_id]['spells'][num]['costType']
    if cost == "0" # Mana-less
      cost = @data['data'][@champ_name_id]['spells'][num]['resource'] # Non-mana resource
      if cost == "" # No cost for spell (i.e. passive or toggle)
        cost = "0"
      end
      cost_type = ""
    end
    @spell_cost[key] = "#{cost} #{cost_type}"
    
    @spell_range[key] = @data['data'][@champ_name_id]['spells'][num]['rangeBurn']
    @spell_descripion[key] = @data['data'][@champ_name_id]['spells'][num]['tooltip']
  end
end
