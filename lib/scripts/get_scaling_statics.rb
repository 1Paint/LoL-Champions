# Find all champions whose ranges, cooldowns, or costs scale with stats.

require 'httparty'

# Obtain all champions.
url = "http://ddragon.leagueoflegends.com/cdn/6.1.1/data/en_US/champion.json"
response = HTTParty.get(url)
champions = response.parsed_response

cooldown_info = ['---cooldowns---']
range_info = ['---ranges---']
cost_info = ['---costs---']
resource_info = ['---resources---']

champions['data'].each do |champ, info|   
  champ_name_id = info['id'] 

  url = "http://ddragon.leagueoflegends.com/cdn/6.1.1/data/en_US/champion/#{champ_name_id}.json"
  response = HTTParty.get(url)
  data = response.parsed_response
  
  spells = data['data'][champ_name_id]['spells']
  
  spells.each do |spell|
    cooldown = spell['cooldownBurn']
    range = spell['rangeBurn']
    cost = spell['costBurn']
    resource = spell['resource']
    
    if cooldown =~ /{{(\s[eaf]\d*\s)}}/
      cooldown_info = cooldown_info << champ_name_id
    end
    
    if range =~ /{{(\s[eaf]\d*\s)}}/
      range_info = range_info << champ_name_id
    end
    
    if cost =~ /{{(\s[eaf]\d*\s)}}/
      cost_info = cost_info << champ_name_id
    end
    
    if resource =~ /{{(\s[eaf]\d*\s)}}/
      resource_info = resource_info << champ_name_id
    end
  end
end

# List all champions pertaining to scaling cooldowns, ranges, costs.
puts cooldown_info
puts range_info
puts cost_info
puts resource_info