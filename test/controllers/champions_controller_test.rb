require 'test_helper'

class ChampionsControllerTest < ActionController::TestCase
  
  test "find champion with apostrophe in name" do
    champ_name = "Kha'Zix"
    @champion = Champion.find_by_name(champ_name)
    assert_not @champion.nil?
    assert_equal @champion.name, "Kha'Zix"
  end
  
  test "find champion without apostrophe in name" do
    champ_name = "Thresh"
    @champion = Champion.find_by_name(champ_name)
    assert_not @champion.nil?
    assert_equal @champion.name, "Thresh"
  end
  
  test "render page of champion with apostrophe in name" do
    get :show, id: "Kha'Zix"
    assert_template 'champions/show'
  end
end
