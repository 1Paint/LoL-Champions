require 'test_helper'

class ChampPagesTest < ActionDispatch::IntegrationTest
  
  test "successfully load all champion pages and no unassigned values on pages" do
    Champion.all.each do |champ|
      get "/champions/#{champ.champ_name_id}"
      assert_response :success
      assert_template 'champions/show'
      puts champ.champ_name_id
      assert_no_match "{{", response.body
    end
  end
end
