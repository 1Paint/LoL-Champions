# Get the resource of each champion.

current_version = "6.9.1"

require 'httparty'

# Obtain all champions.
url = "http://ddragon.leagueoflegends.com/cdn/#{current_version}/data/en_US/champion.json"
response = HTTParty.get(url)
champions = response.parsed_response

resource_hash = Hash.new

champions['data'].each do |champ, info|   
  champ_name_id = info['id']
  champ_name = info['name']

  url = "http://ddragon.leagueoflegends.com/cdn/#{current_version}/data/en_US/champion/#{champ_name_id}.json"
  response = HTTParty.get(url)
  data = response.parsed_response
  
  resource = data['data'][champ_name_id]['partype']
  
  if resource_hash[resource.to_sym].nil?
    resource_hash[resource.to_sym] = [1]
    resource_hash[resource.to_sym] << champ_name
  else
    resource_hash[resource.to_sym][0] += 1
    resource_hash[resource.to_sym] << champ_name
  end
end

# List all champions resources and frequency of each.
resource_hash.sort.each do |res, freq_n_name|
  puts "#{res}: #{freq_n_name}"
end