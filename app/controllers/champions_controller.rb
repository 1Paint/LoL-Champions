class ChampionsController < ApplicationController
  before_action :set_current_version  # from application_contoller.rb
  include ChampionsHelper
  
  def index
    check_version # From applications controller.
  end
  
  def show
    champ_name_id = params[:id]
    @half_num = params[:half_num]
    
    version = params[:version]
    if version
      @version = version
    else
      @version = @current_version
    end
    
    begin
      get_champ(champ_name_id, @version) # from champions_helper.rb
    rescue NoMethodError
      respond_to do |format|
        # Add format.html? Error won't be raised outside of 'Compare' page.
        format.js { render :action => "invalid" }
      end
    else
      respond_to do |format|
        format.html
        format.js
      end
    end
  end
  
  def compare
    champ_name_id = Champion.first.champ_name_id
    get_champ(champ_name_id, @current_version)
    
    # Get all champion names and versions. From applications controller.
    @champs_list = get_champs(@current_version)
    @versions_list = get_versions
  end
end
