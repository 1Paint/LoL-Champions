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
  champ_name = info['name']

  url = "http://ddragon.leagueoflegends.com/cdn/#{current_version}/data/en_US/champion/#{champ_name_id}.json"
  response = HTTParty.get(url)
  data = response.parsed_response
  
  for num in 0..3
    resource = data['data'][champ_name_id]['spells'][num]['resource']
    cost = data['data'][champ_name_id]['spells'][num]['costType']
    
    if resource_hash[resource.to_sym].nil?
      resource_hash[resource.to_sym] = {}
      resource_hash[resource.to_sym][:freq] = 1
      resource_hash[resource.to_sym][champ_name] = 1
    else
      resource_hash[resource.to_sym][:freq] += 1
      if resource_hash[resource.to_sym][champ_name].nil?
        resource_hash[resource.to_sym][champ_name] = 1
      else
        resource_hash[resource.to_sym][champ_name] += 1
      end
    end
    
    if cost_hash[cost.to_sym].nil?
      cost_hash[cost.to_sym] = {}
      cost_hash[cost.to_sym][:freq] = 1
      cost_hash[cost.to_sym][champ_name] = 1
    else
      cost_hash[cost.to_sym][:freq] += 1
      if cost_hash[cost.to_sym][champ_name].nil?
        cost_hash[cost.to_sym][champ_name] = 1
      else
        cost_hash[cost.to_sym][champ_name] += 1
      end
    end
  end
  
end

# List all champions resources and frequency of each.
resource_hash = resource_hash.sort_by{|k,v| v[:freq]}
resource_hash.each do |res, freq|
  puts "#{res}: #{freq}"
end

puts ""

cost_hash = cost_hash.sort_by{|k,v| v[:freq]}
cost_hash.each do |res, freq|
  puts "#{res}: #{freq}"
end