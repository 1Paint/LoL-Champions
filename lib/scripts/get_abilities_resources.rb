# Get the resource of each champion.

current_version = "6.9.1"

require 'httparty'

# Obtain all champions.
url = "http://ddragon.leagueoflegends.com/cdn/#{current_version}/data/en_US/champion.json"
response = HTTParty.get(url)
champions = response.parsed_response

resource_hash = Hash.new
cost_hash = Hash.new

champions['data'].each do |champ, info|   
  champ_name_id = info['id'] 

  url = "http://ddragon.leagueoflegends.com/cdn/#{current_version}/data/en_US/champion/#{champ_name_id}.json"
  response = HTTParty.get(url)
  data = response.parsed_response
  
  for num in 0..3
    cost = data['data'][champ_name_id]['spells'][num]['costType']
    resource = data['data'][champ_name_id]['spells'][num]['resource']
    
    if resource_hash[resource.to_sym].nil?
      resource_hash[resource.to_sym] = 1
    else
      resource_hash[resource.to_sym] += 1
    end
    
    if cost_hash[cost.to_sym].nil?
      cost_hash[cost.to_sym] = 1
    else
      cost_hash[cost.to_sym] += 1
    end
  end
  
end

# List all champions resources and frequency of each.
resource_hash.sort.each do |res, freq|
  puts "#{res}: #{freq}"
end
cost_hash.sort.each do |res, freq|
  puts "#{res}: #{freq}"
end