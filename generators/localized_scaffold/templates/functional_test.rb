require 'test_helper'

class <%= controller_class_name %>ControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:<%= table_name %>)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create <%= file_name %>" do
    assert_difference('<%= class_name %>.count') do
      post :create, :<%= file_name %> => { }
    end

<%- if has_parent? -%>
    assert_redirected_to <%= path_of_with_parent_if_any(nil, "assigns(:#{file_name})", "assigns(:#{parent.file_name})") %>
<%- else -%>
    assert_redirected_to <%= path_of_with_parent_if_any(nil, "assigns(:#{file_name})") %>
<%- end -%>
  end

  test "should show <%= file_name %>" do
    get :show, :id => <%= table_name %>(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => <%= table_name %>(:one).to_param
    assert_response :success
  end

  test "should update <%= file_name %>" do
    put :update, :id => <%= table_name %>(:one).to_param, :<%= file_name %> => { }
<%- if has_parent? -%>
    assert_redirected_to <%= path_of_with_parent_if_any(nil, "assigns(:#{file_name})", "assigns(:#{parent.file_name})") %>
<%- else -%>
    assert_redirected_to <%= path_of_with_parent_if_any(nil, "assigns(:#{file_name})") %>
<%- end -%>
  end

  test "should destroy <%= file_name %>" do
    assert_difference('<%= class_name %>.count', -1) do
      delete :destroy, :id => <%= table_name %>(:one).to_param
    end

    assert_redirected_to <%= path_of_with_parent_if_any %>
  end
end
