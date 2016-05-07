class StaticsController < ApplicationController
  before_action :set_current_version  # from application_contoller.rb
  
  def home
    @roles_hash = Hash.new { |h, k| h[k] = [] }
    
    # Store all champion name IDs and names---used to generate images and links.
    Champion.all.each do |champ|
      champ_name = champ.name # Champion name, e.g. Kha'Zix, Master Yi
      champ_name_id = champ.champ_name_id # Champion name ID, e.g. KhaZix, MasterYi
      
      # Store champions in their respective roles---used to enable filtering.
      @roles_hash[:All] << [champ_name, champ_name_id]
      @roles_hash["#{Champion.find_by(champ_name_id: champ_name_id).primary}".to_sym] << [champ_name, champ_name_id]
      # Sort champions by name.
      @roles_hash.each do |key, array|
        @roles_hash[key] = @roles_hash[key].sort
      end
    end
  end
  
  def contact
  end
  
  def missingdata
    check_version # From applications controller.
  end
end
