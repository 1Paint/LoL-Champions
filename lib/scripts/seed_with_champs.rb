require 'httparty'

url = "http://ddragon.leagueoflegends.com/cdn/6.1.1/data/en_US/champion.json"
response = HTTParty.get(url)
data = response.parsed_response

# Find champion name IDs, IDs, and names.
data['data'].each do |champ, info|
  champ_name_id = info['id']  # name ID: Zed -- Khazix --- MasterYi ---
  champ_key = info['key']     #      ID: 238 -- 121 ------ 11 ---------
  name = info['name']         #    name: Zed -- Kha'Zix -- Master Yi --
  
  puts champ_name_id + " " + champ_key + " " + name
end