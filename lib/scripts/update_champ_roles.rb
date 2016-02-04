require 'httparty'

# Obtain all champions.
url = "http://ddragon.leagueoflegends.com/cdn/6.1.1/data/en_US/champion.json"
response = HTTParty.get(url)
champions = response.parsed_response

# Get and save the primary and secondary roles of each champion.
champions['data'].each do |champ, info|   
  champ_name_id = info['id'] 

  url = "http://ddragon.leagueoflegends.com/cdn/6.1.1/data/en_US/champion/#{champ_name_id}.json"
  response = HTTParty.get(url)
  data = response.parsed_response
  
  primary_role = data['data'][champ_name_id]['tags'][0]
  secondary_role = data['data'][champ_name_id]['tags'][1]

  champion = Champion.find_by(champ_name_id: champ_name_id)
  champion.update(primary: primary_role,
                  secondary: secondary_role)
end