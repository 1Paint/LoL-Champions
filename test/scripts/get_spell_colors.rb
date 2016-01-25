require 'httparty'

# Obtain all champions.
url = "http://ddragon.leagueoflegends.com/cdn/6.1.1/data/en_US/champion.json"
response = HTTParty.get(url)
champions = response.parsed_response

colors_hash = Hash.new

# Get the colors used for each spell of each champion.
champions['data'].each do |champ, info|   
  champ_name_id = info['id'] 

  url = "http://ddragon.leagueoflegends.com/cdn/6.2.1/data/en_US/champion/#{champ_name_id}.json"
  response = HTTParty.get(url)
  data = response.parsed_response
  
  for i in 0..3
    spell_description = data['data'][champ_name_id]['spells'][i]['tooltip']
    colors_array = []
    colors_array = spell_description.scan(/color\h{3,6}/)
    colors_array.each do |color|
      colors_hash[color] = true
    end
  end
end

# Print out all colors for use in CSS.
colors_hash.each do |color, bool|
  puts ".#{color} {\n\s color: ##{color[5..-1]};\n}"
end