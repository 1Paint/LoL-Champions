require 'httparty'

def spell_img_link(spell_name)
  "http://ddragon.leagueoflegends.com/cdn/6.1.1/img/spell/#{spell_name}.png"
end

champ_name = "Thresh"

url = "http://ddragon.leagueoflegends.com/cdn/6.1.1/data/en_US/champion/#{champ_name}.json"
response = HTTParty.get(url)
data = response.parsed_response

@passive = data['data'][champ_name]['passive']['name']
passive_img_name = data['data'][champ_name]['passive']['image']['full']
@passive_img_url = spell_img_link(passive_img_name)
@passive_description = data['data'][champ_name]['passive']['description']

@q_name = data['data'][champ_name]['spells'][0]['name']
q_img_name = data['data'][champ_name]['spells'][0]['id']
@q_img_url = spell_img_link(q_img_name)
@q_descripion = data['data'][champ_name]['spells'][0]['tooltip']

puts q_img_name
puts @q_img_url