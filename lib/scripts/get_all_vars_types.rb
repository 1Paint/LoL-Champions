require 'httparty'

current_version = "6.9.1"

# Obtain all champions.
url = "http://ddragon.leagueoflegends.com/cdn/#{current_version}/data/en_US/champion.json"
response = HTTParty.get(url)
champions = response.parsed_response

vars_hash = Hash.new

# Get the spell resource types of each champion.
# Volume of calculations = #champions x #spells x #avg_vars_per_spell
champions['data'].each do |champ, info|   
  champ_name_id = info['id'] 

  url = "http://ddragon.leagueoflegends.com/cdn/#{current_version}/data/en_US/champion/#{champ_name_id}.json"
  response = HTTParty.get(url)
  data = response.parsed_response
  
  for num in 0..3  # 4 spells (Q, W, E, R)
    vars = data['data'][champ_name_id]['spells'][num]['vars']
    vars.each do |hash|
      spell_resource = hash['link']
      
      if vars_hash[spell_resource.to_sym].nil?
        vars_hash[spell_resource.to_sym] = [1]
      else
        vars_hash[spell_resource.to_sym][0] += 1
      end
    end
  end
end

# Alphabetize hash keys.
vars_hash = vars_hash.sort.to_h

# List all spell resource types and frequency.
vars_hash.each do |resource, freq|
  puts "#{resource}: #{freq}"
end