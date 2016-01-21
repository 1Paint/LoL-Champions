class Champion < ActiveRecord::Base
  
  attr_accessor :champ_img_url, :title, :lore,
                :stat_summary, :stat, :stat_range,
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
  def retrieve(champ_name)
    # Create empty hashes to store spells' details.
    initialize_spells
    
    # Create empty hashes to store champion stats (HP, attack, defense, etc).
    initialize_stats
    
    @champ_name = champ_name
    
    url = "http://ddragon.leagueoflegends.com/cdn/6.1.1/data/en_US/champion/#{@champ_name}.json"
    response = HTTParty.get(url)
    @data = response.parsed_response
    
    # Champion info.
    @champ_img_url = "http://ddragon.leagueoflegends.com/cdn/img/champion/loading/#{@champ_name}_0.jpg"
    @title = @data['data'][@champ_name]['title']
    @lore = @data['data'][@champ_name]['lore']
    
    # Retrieve champion stats.
    get_stats
    
    # Retrieve champion stats at levels 1 and 18.
    get_stats_ranges
    
    # Passive info.
    @passive = @data['data'][@champ_name]['passive']['name']
    passive_img_name = @data['data'][@champ_name]['passive']['image']['full']
    @passive_img_url = "http://ddragon.leagueoflegends.com/cdn/6.1.1/img/passive/#{passive_img_name}"
    @passive_description = @data['data'][@champ_name]['passive']['description']
    
    # Retrieve spells info.
    get_spell(:q, 0)
    get_spell(:w, 1)
    get_spell(:e, 2)
    get_spell(:r, 3)
  end
  
  # Retrieve champion stats such as HP, attack, defense, etc.
  def get_stats
    # attack, magic, defense, difficulty.
    @data['data'][@champ_name]['info'].each do |stat_name, value|
      @stat_summary[:"#{stat_name}"] = value
    end
    
    # hp, hpperlevel, mp, mpperlevel, movespeed, armor, armorperlevel,
    # spellblock, spellblockperlevel, attackrange, hpregen, hpregenperlevel,
    # mpregen, mpregenperlevel, crit, critperlevel, attackdamage,
    # attackdamageperlevel, attackspeedoffset, attackspeedperlevel.
    @data['data'][@champ_name]['stats'].each do |stat_name, value|
      @stat[:"#{stat_name}"] = value
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
    
    @stat_range = { hp: { name: "HP",
                          min: @stat[:hp],
                          max: @stat_max[:hp] },
               hpregen: { name: "HP Regen",
                          min: @stat[:hpregen],
                          max: @stat_max[:hpregen] },
                    mp: { name: "MP",
                          min: @stat[:mp],
                          max: @stat_max[:mp] },
               mpregen: { name: "MP Regen",
                          min: @stat[:mpregen],
                          max: @stat_max[:mpregen] },
          attackdamage: { name: "Attack Damage",
                          min: @stat[:attackdamage],
                          max: @stat_max[:attackdamage] },
           attackspeed: { name: "Attack Speed",
                          min: base_attack_speed,
                          max: @stat_max[:attackspeed] },
                 armor: { name: "Armor",
                          min: @stat[:armor],
                          max: @stat_max[:armor] },
            spellblock: { name: "Magic Resist",
                          min: @stat[:spellblock],
                          max: @stat_max[:spellblock] } }
  end
  
  # Retrieve spell name, image, and description.
  def get_spell(key, num)
    @spell_name[key] = @data['data'][@champ_name]['spells'][num]['name']
    @spell_img_name[key] = @data['data'][@champ_name]['spells'][num]['id']
    @spell_img_url[key] = "http://ddragon.leagueoflegends.com/cdn/6.1.1/img/spell/#{@spell_img_name[key]}.png"
    @spell_cooldown[key] = @data['data'][@champ_name]['spells'][num]['cooldownBurn']
    
    # Find the resource used for the spell.
    cost = @data['data'][@champ_name]['spells'][num]['costBurn']
    cost_type = @data['data'][@champ_name]['spells'][num]['costType']
    if cost == "0" # Mana-less
      cost = @data['data'][@champ_name]['spells'][num]['resource'] # Non-mana resource
      if cost == "" # No cost for spell (i.e. passive or toggle)
        cost = "0"
      end
      cost_type = ""
    end
    @spell_cost[key] = "#{cost} #{cost_type}"
    
    @spell_range[key] = @data['data'][@champ_name]['spells'][num]['rangeBurn']
    @spell_descripion[key] = @data['data'][@champ_name]['spells'][num]['tooltip']
  end
end
