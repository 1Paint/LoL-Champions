class ItemsController < ApplicationController
  
  def index
    url = "http://ddragon.leagueoflegends.com/cdn/6.3.1/data/en_US/item.json"
    response = HTTParty.get(url)
    data = response.parsed_response
    
    @item_ids = data['data']
  end
end
