class Champion < ActiveRecord::Base
  
  attr_accessor :champ_img_url, :title, :lore, 
                :passive, :passive_img_url, :passive_description,
                :spell_name, :spell_img_name, :spell_img_url, 
                :spell_cooldown, :spell_cost, :spell_range, :spell_descripion
  
  def initialize
    @spell_name = Hash.new
    @spell_img_name = Hash.new
    @spell_img_url = Hash.new
    @spell_cooldown = Hash.new
    @spell_cost = Hash.new
    @spell_range = Hash.new
    @spell_descripion = Hash.new
  end
  
  # Retrieve champion info, making attributes available to the controller/view.
  def retrieve(champ_name)
    initialize
    
    @champ_name = champ_name
    
    url = "http://ddragon.leagueoflegends.com/cdn/6.1.1/data/en_US/champion/#{@champ_name}.json"
    response = HTTParty.get(url)
    @data = response.parsed_response
    
    @champ_img_url = "http://ddragon.leagueoflegends.com/cdn/img/champion/loading/#{@champ_name}_0.jpg"
    @title = @data['data'][@champ_name]['title']
    @lore = @data['data'][@champ_name]['lore']
    
    @passive = @data['data'][@champ_name]['passive']['name']
    passive_img_name = @data['data'][@champ_name]['passive']['image']['full']
    @passive_img_url = "http://ddragon.leagueoflegends.com/cdn/6.1.1/img/passive/#{passive_img_name}"
    @passive_description = @data['data'][@champ_name]['passive']['description']
    
    get_spell(:q, 0)
    get_spell(:w, 1)
    get_spell(:e, 2)
    get_spell(:r, 3)
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
      cost = @data['data'][@champ_name]['spells'][num]['resource']
      cost_type = ""
    end
    @spell_cost[key] = "#{cost} #{cost_type}"
    
    @spell_range[key] = @data['data'][@champ_name]['spells'][num]['rangeBurn']
    @spell_descripion[key] = @data['data'][@champ_name]['spells'][num]['tooltip']
  end
end
