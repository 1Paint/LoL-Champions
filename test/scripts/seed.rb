require 'httparty'

url = "http://ddragon.leagueoflegends.com/cdn/6.1.1/data/en_US/champion.json"
response = HTTParty.get(url)
data = response.parsed_response

# Obtain the names and IDs of all current champions
data['data'].each do |champ, info|
  name = info['id']
  champ_id = info['key']
  
  puts name
  puts champ_id
end