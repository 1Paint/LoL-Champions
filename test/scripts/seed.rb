require 'httparty'

api_key = 'API_KEY'

url = "https://global.api.pvp.net/api/lol/static-data/na/v1.2/champion?champData=info&api_key=#{api_key}"
response = HTTParty.get(url)
data = response.parsed_response

# Obtain the names and IDs of all current champions
data['data'].each do |champ, info|
  name = info['name']
  champ_id = info['id']
  
  puts name
  puts champ_id
end