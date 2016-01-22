require 'httparty'

# Obtain all champions.
url = "http://ddragon.leagueoflegends.com/cdn/6.1.1/data/en_US/champion.json"
response = HTTParty.get(url)
champions = response.parsed_response

# Print the resource of each champion.
champions['data'].each do |champ, info|   
  champ_name_id = info['id'] 

  url = "http://ddragon.leagueoflegends.com/cdn/6.1.1/data/en_US/champion/#{champ_name_id}.json"
  response = HTTParty.get(url)
  data = response.parsed_response
  
  resource = data['data'][champ_name_id]['partype']
  
  puts champ_name_id + ": " + resource
end