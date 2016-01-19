class ChampionsController < ApplicationController
  
  def index
  end
  
  def show
    champ_name = params[:id]
    @champion = Champion.find_by_name(champ_name)
    
    url = "http://ddragon.leagueoflegends.com/cdn/6.1.1/data/en_US/champion/#{champ_name}.json"
    response = HTTParty.get(url)
    data = response.parsed_response
    
    @champ_image_url = "http://ddragon.leagueoflegends.com/cdn/img/champion/loading/#{champ_name}_0.jpg"
    
    @passive = data['data'][champ_name]['passive']['name']
    @passive_description = data['data'][champ_name]['passive']['description']
    
    @Q_name = data['data'][champ_name]['spells'][0]['name']
    @Q_descripion = data['data'][champ_name]['spells'][0]['tooltip']
    
    @W_name = data['data'][champ_name]['spells'][1]['name']
    @W_descripion = data['data'][champ_name]['spells'][1]['tooltip']
    
    @E_name = data['data'][champ_name]['spells'][2]['name']
    @E_descripion = data['data'][champ_name]['spells'][2]['tooltip']
    
    @R_name = data['data'][champ_name]['spells'][3]['name']
    @R_descripion = data['data'][champ_name]['spells'][3]['tooltip']
  end
end
