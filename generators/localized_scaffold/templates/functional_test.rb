require 'test_helper'

class <%= controller_class_name %>ControllerTest < ActionController::TestCase
<%- if has_parent? -%>
  setup do
    <%= parent.file_name %> = <%= parent.class_name %>.new
    <%= parent.file_name %>.id = 1
    <%= parent.file_name %>.save!
  end

<%- end -%>
  test "should get index" do
<%- if has_parent? -%>
    get :index, :<%= parent.file_name %>_id => <%= table_name %>(:one).<%= parent.file_name %>_id
<%- else -%>
    get :index
<%- end -%>
    assert_response :success
    assert_not_nil assigns(:<%= table_name %>)
  end

  test "should get new" do
<%- if has_parent? -%>
    get :new, :<%= parent.file_name %>_id => <%= table_name %>(:one).<%= parent.file_name %>_id
<%- else -%>
    get :new
<%- end -%>
    assert_response :success
  end

  test "should create <%= file_name %>" do
    assert_difference('<%= class_name %>.count') do
<%- if has_parent? -%>
    post :create, :<%= file_name %> => { :<%= parent.file_name %>_id => <%= table_name %>(:one).<%= parent.file_name %>_id }, :<%= parent.file_name %>_id => <%= table_name %>(:one).<%= parent.file_name %>_id
<%- else -%>
    post :create, :<%= file_name %> => { }
<%- end -%>
    end

<%- if has_parent? -%>
    assert_redirected_to <%= path_of_with_parent_if_any(:show, "assigns(:#{file_name})", "assigns(:#{parent.file_name})") %>
<%- else -%>
    assert_redirected_to <%= path_of_with_parent_if_any(:show, "assigns(:#{file_name})") %>
<%- end -%>
  end

  test "should show <%= file_name %>" do
<%- if has_parent? -%>
    get :show, :id => <%= table_name %>(:one).to_param, :<%= parent.file_name %>_id => <%= table_name %>(:one).<%= parent.file_name %>_id
<%- else -%>
    get :show, :id => <%= table_name %>(:one).to_param
<%- end -%>
    assert_response :success
  end

  test "should get edit" do
<%- if has_parent? -%>
    get :edit, :id => <%= table_name %>(:one).to_param, :<%= parent.file_name %>_id => <%= table_name %>(:one).<%= parent.file_name %>_id
<%- else -%>
    get :edit, :id => <%= table_name %>(:one).to_param
<%- end -%>
    assert_response :success
  end

  test "should update <%= file_name %>" do
<%- if has_parent? -%>
    put :update, :id => <%= table_name %>(:one).to_param, :<%= file_name %> => { :<%= parent.file_name %>_id => <%= table_name %>(:one).<%= parent.file_name %>_id }, :<%= parent.file_name %>_id => <%= table_name %>(:one).<%= parent.file_name %>_id
<%- else -%>
    put :update, :id => <%= table_name %>(:one).to_param, :<%= file_name %> => { }
<%- end -%>
<%- if has_parent? -%>
    assert_redirected_to <%= path_of_with_parent_if_any(:show, "assigns(:#{file_name})", "assigns(:#{parent.file_name})") %>
<%- else -%>
    assert_redirected_to <%= path_of_with_parent_if_any(:show, "assigns(:#{file_name})") %>
<%- end -%>
  end

  test "should destroy <%= file_name %>" do
    assert_difference('<%= class_name %>.count', -1) do
<%- if has_parent? -%>
      delete :destroy, :id => <%= table_name %>(:one).to_param, :<%= parent.file_name %>_id => <%= table_name %>(:one).<%= parent.file_name %>_id
<%- else -%>
      delete :destroy, :id => <%= table_name %>(:one).to_param
<%- end -%>
    end

<%- if has_parent? -%>
    assert_redirected_to <%= path_of_with_parent_if_any(nil, "assigns(:#{file_name})", "assigns(:#{parent.file_name})") %>
<%- else -%>
    assert_redirected_to <%= path_of_with_parent_if_any %>
<%- end -%>
  end
end
