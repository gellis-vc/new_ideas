require File.dirname(__FILE__) + '/../test_helper'
require 'votes_controller'

class MapsControllerTest < Test::Unit::TestCase
  scenario :basic

  def setup
    @controller = MapsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @barbershop_discount.inventor = @admin_user  # so it shows up on the map (Sally has a foreign zip)
    @barbershop_discount.save!
  end
  
  def test_map_specific_idea
    get :show, :idea_ids => @walruses_in_stores.id
    assert_marker @walruses_in_stores
    assert_no_marker @barbershop_discount
  end
  
  def test_map_multiple_specific_ideas
    get :show, :idea_ids => "#{@walruses_in_stores.id} #{@barbershop_discount.id}"
    assert_marker @walruses_in_stores
    assert_marker @barbershop_discount
  end
  
  def test_map_by_specific_postal_code
    get :show, :search => {:postal_code => '55103'}
    assert_marker @barbershop_discount
    assert_no_marker @walruses_in_stores
  end
  
  def test_map_by_user_postal_code
    login_as @quentin
    get :show
    assert_marker @walruses_in_stores
    assert_no_marker @barbershop_discount
  end
  
  def test_map_no_params_and_not_logged_in
    get :show
    assert_no_marker @walruses_in_stores
    assert_no_marker @barbershop_discount
  end
  
  def test_map_no_params_and_user_has_no_postal_code
    login_as @sally
    get :show
    assert_no_marker @walruses_in_stores
    assert_no_marker @barbershop_discount
  end
  
private

  def assert_marker(idea)
    marker, lat_lon, popup_content = find_marker(idea)
    assert popup_content, "Expected map marker for #{idea.inspect}, but found none.\nResponse:\n#{@response.body}"
    lat_lon = lat_lon.split(',').map{ |x| x.strip.to_f }
    assert_in_delta idea.inventor.postal_code.lat, lat_lon[0], 0.2
    assert_in_delta idea.inventor.postal_code.lon, lat_lon[1], 0.2
    popup_content
  end
  
  def assert_no_marker(idea)
    marker, lat_lon, popup_content = find_marker(idea)
    assert !marker, "Expected no marker for #{idea.inspect}, but found: #{marker}"
  end
  
  # Find marker for given idea by searching for link in popup content. Return entire marker, lat/lon and popup content.
  def find_marker(idea)
    postal = idea.inventor.postal_code
    if @response.body =~ /addInfoWindowToMarker\(new +GMarker\(new +GLatLng\((.*?)\).*?\), *("([^"]|\\\")*<a href=\\"#{idea_path(idea)}\\"([^"]|\\\")*?")/
      [$&, $1, $2]
    end
  end

end
