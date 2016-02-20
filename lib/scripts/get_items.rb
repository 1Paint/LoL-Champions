require 'httparty'

url = "http://ddragon.leagueoflegends.com/cdn/6.3.1/data/en_US/item.json"
response = HTTParty.get(url)
data = response.parsed_response

@item_ids = data['data']

@item_ids.each do |item_id, item_info|
  puts item_info['name']
end