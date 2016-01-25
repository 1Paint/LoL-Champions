require 'httparty'

# Obtain all champions.
url = "http://ddragon.leagueoflegends.com/cdn/6.1.1/data/en_US/champion.json"
response = HTTParty.get(url)
champions = response.parsed_response

resource_hash = Hash.new

# Get the resource of each champion.
champions['data'].each do |champ, info|   
  champ_name_id = info['id'] 

  url = "http://ddragon.leagueoflegends.com/cdn/6.1.1/data/en_US/champion/#{champ_name_id}.json"
  response = HTTParty.get(url)
  data = response.parsed_response
  
  resource = data['data'][champ_name_id]['partype']
  
  if resource_hash[resource.to_sym].nil?
    resource_hash[resource.to_sym] = 1
  else
    resource_hash[resource.to_sym] += 1
  end
end

# List all champions resources and frequency of each.
resource_hash.sort.each do |res, freq|
  puts "#{res}: #{freq}"
end