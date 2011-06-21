require 'test_helper'

class DiagramsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:diagrams)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create diagram" do
    assert_difference('Diagram.count') do
      post :create, :diagram => { }
    end

    assert_redirected_to diagram_path(assigns(:diagram))
  end

  test "should show diagram" do
    get :show, :id => diagrams(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => diagrams(:one).to_param
    assert_response :success
  end

  test "should update diagram" do
    put :update, :id => diagrams(:one).to_param, :diagram => { }
    assert_redirected_to diagram_path(assigns(:diagram))
  end

  test "should destroy diagram" do
    assert_difference('Diagram.count', -1) do
      delete :destroy, :id => diagrams(:one).to_param
    end

    assert_redirected_to diagrams_path
  end
end
