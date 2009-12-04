require 'test_helper'

class CompetitionsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:competitions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create competition" do
    assert_difference('Competition.count') do
      post :create, :competition => { }
    end

    assert_redirected_to competition_path(assigns(:competition))
  end

  test "should show competition" do
    get :show, :id => competitions(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => competitions(:one).to_param
    assert_response :success
  end

  test "should update competition" do
    put :update, :id => competitions(:one).to_param, :competition => { }
    assert_redirected_to competition_path(assigns(:competition))
  end

  test "should destroy competition" do
    assert_difference('Competition.count', -1) do
      delete :destroy, :id => competitions(:one).to_param
    end

    assert_redirected_to competitions_path
  end
end
