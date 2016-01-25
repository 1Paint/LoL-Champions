require 'httparty'

# Obtain Zed.
url = "http://ddragon.leagueoflegends.com/cdn/6.1.1/data/en_US/champion/Zed.json"
response = HTTParty.get(url)
data = response.parsed_response

# Description for Zed's Q, which includes base damage numbers and damage scaling (e.g. +60% bonus AD).
zed_q = data['data']['Zed']['spells'][0]['tooltip']

# Base damage values where {{ e1 }} is replaced by effectBurn[1].
effectBurn = data['data']['Zed']['spells'][0]['effectBurn']

# Store corresponding eX values with their damage values (e.g. e1: "20/40/60/80/100").
base_damage = Hash.new
for i in 0..(effectBurn.length-1)
  if effectBurn[i] != nil
    base_damage["{{ e#{i} }}"] = effectBurn[i]
  end
end

puts base_damage

puts zed_q
zed_q = zed_q.gsub(/{{(\se\d*\s)}}/, base_damage)
puts zed_q
