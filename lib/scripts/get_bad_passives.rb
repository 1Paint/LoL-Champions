# Get all champions with BadDesc passives.

current_version = "6.9.1"

require 'httparty'

# Obtain all champions.
url = "http://ddragon.leagueoflegends.com/cdn/#{current_version}/data/en_US/champion.json"
response = HTTParty.get(url)
champions = response.parsed_response

bad_passive_champs = []

champions['data'].each do |champ, info|   
  champ_name_id = info['id'] 

  url = "http://ddragon.leagueoflegends.com/cdn/#{current_version}/data/en_US/champion/#{champ_name_id}.json"
  response = HTTParty.get(url)
  data = response.parsed_response
  
  passive_description = data['data'][champ_name_id]['passive']['description']
  if passive_description == "BadDesc"
    bad_passive_champs << champ_name_id
  end
end

# List all champions resources and frequency of each.
bad_passive_champs.each do |champ|
  puts champ
end