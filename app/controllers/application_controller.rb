class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  def get_version
    url = "https://ddragon.leagueoflegends.com/api/versions.json"
    response = HTTParty.get(url)
    data = response.parsed_response
    @current_version = data[0]
  end
end
