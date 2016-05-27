current_version = "6.10.1"

require 'httparty'

unused_vars = {q: {}, w: {}, e: {}, r: {}}
buttons = { q: 0, w: 1, e: 2, r: 3 }
spell_description = {}
vars_requested = {}
vars_available = {}

# Get champion data.
champ_name_id = "Azir"
url = "http://ddragon.leagueoflegends.com/cdn/#{current_version}/data/en_US/champion/#{champ_name_id}.json"
response = HTTParty.get(url)
data = response.parsed_response

buttons.each do |button, num|
  spell_description[button] = data['data'][champ_name_id]['spells'][num]['tooltip']
  vars_requested[button] = {}
  spell_description[button].scan(/{{\s(.*?)\s}}/).each do |var|
    vars_requested[button][var[0].to_sym] = true
  end
  vars_available[button] = {}
  
  e_vars = data['data'][champ_name_id]['spells'][num]['effectBurn']
  i = 0
  e_vars.each do |values|
    vars_available[button]["e#{i}".to_sym] = values
    i += 1
  end
  v_vars = data['data'][champ_name_id]['spells'][num]['vars']
  v_vars.each do |index|
    vars_available[button][index['key'].to_sym] = index['coeff']
  end
  
  vars_available[button].each do |var, value|
    if !vars_requested[button].key?(var)
      unused_vars[button][var.to_sym] = value
    end
  end
end

puts "unused: #{unused_vars}"