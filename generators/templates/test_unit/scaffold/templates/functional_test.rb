require 'test_helper'

class <%= controller_class_name %>ControllerTest < ActionController::TestCase
  setup do
    @<%= file_name %> = <%= plural_name %>(:one)
<%- if has_belongsto? -%>
    @<%= belongsto.file_name %> = <%= belongsto.plural_name %>(:one)

    @<%= belongsto.file_name %>.save!

    @<%= file_name %>.<%= belongsto.file_name %>_id = @<%= belongsto.file_name %>.id

<%- end -%>
    @<%= file_name %>.save!
  end

<% unless options[:singleton] -%>
  test "should get index" do
<%- if has_belongsto? -%>
    get :index, :<%= belongsto.file_name %>_id => @<%= belongsto.file_name %>.to_param
<%- else -%>
    get :index
<%- end -%>

    assert_response :success
    assert_not_nil assigns(:<%= table_name %>)
  end

<%- end -%>
  test "should get new" do
<%- if has_belongsto? -%>
    get :new, :<%= belongsto.file_name %>_id => @<%= belongsto.file_name %>.to_param
<%- else -%>
    get :new
<%- end -%>

    assert_response :success
  end

  test "should create <%= file_name %>" do
    assert_difference('<%= class_name %>.count') do
<%- if has_belongsto? -%>
      data = { :<%= belongsto.file_name %>_id => @<%= belongsto.file_name %>.to_param }
<%- else -%>
      data = {}
<%- end -%>
<%- if has_searchbar? -%>
      data[:<%= searchbar %>] = "Some <%= searchbar %>"
<%- end -%>

<%- if has_belongsto? -%>
      post :create, :<%= belongsto.file_name %>_id => @<%= belongsto.file_name %>.to_param, :<%= file_name %> => data
<%- else -%>
      post :create, :<%= file_name %> => data
<%- end -%>
    end

<%- if has_belongsto? -%>
    assert_redirected_to <%= path_of_with_belongsto_if_any(:method => :show, :value1 => "assigns(:#{file_name})", :value2 => "assigns(:#{belongsto.file_name})") %>
<%- else -%>
    assert_redirected_to <%= path_of_with_belongsto_if_any(:method => :show, :value1 => "assigns(:#{file_name})") %>
<%- end -%>
  end

  test "should show <%= file_name %>" do
<%- if has_belongsto? -%>
    get :show, :id => @<%= file_name %>.to_param, :<%= belongsto.file_name %>_id => @<%= belongsto.file_name %>.to_param
<%- else -%>
    get :show, :id => @<%= file_name %>.to_param
<%- end -%>

    assert_response :success
  end

  test "should get edit" do
<%- if has_belongsto? -%>
    get :edit, :id => @<%= file_name %>.to_param, :<%= belongsto.file_name %>_id => @<%= belongsto.file_name %>.to_param
<%- else -%>
    get :edit, :id => @<%= file_name %>.to_param
<%- end -%>

    assert_response :success
  end

  test "should update <%= file_name %>" do
<%- if has_belongsto? -%>
    put :update, :id => @<%= file_name %>.to_param, :<%= file_name %> => { :<%= belongsto.file_name %>_id => @<%= belongsto.file_name %>.to_param },
      :<%= belongsto.file_name %>_id => @<%= belongsto.file_name %>.to_param
<%- else -%>
    put :update, :id => @<%= file_name %>.to_param, :<%= file_name %> => { }
<%- end -%>

<%- if has_belongsto? -%>
    assert_redirected_to <%= path_of_with_belongsto_if_any(:method => :show, :value1 => "assigns(:#{file_name})", :value2 => "assigns(:#{belongsto.file_name})") %>
<%- else -%>
    assert_redirected_to <%= path_of_with_belongsto_if_any(:method => :show, :value1 => "assigns(:#{file_name})") %>
<%- end -%>
  end

  test "should destroy <%= file_name %>" do
    destroyed = @<%= file_name %>

    assert_difference('<%= class_name %>.count', -1) do
<%- if has_belongsto? -%>
      delete :destroy, :id => @<%= file_name %>.to_param, :<%= belongsto.file_name %>_id => @<%= belongsto.file_name %>.to_param
<%- else -%>
      delete :destroy, :id => @<%= file_name %>.to_param
<%- end -%>
    end

<%- if has_belongsto? -%>
    assert_redirected_to <%= path_of_with_belongsto_if_any(:value1 => "assigns(:#{file_name})", :value2 => "assigns(:#{belongsto.file_name})") %><%= has_searchbar? ? ' + "?q=#{destroyed.' + searchbar + '.first}"' : '' %>
<%- else -%>
    assert_redirected_to <%= path_of_with_belongsto_if_any %><%= has_searchbar? ? ' + "?q=#{destroyed.' + searchbar + '.first}"' : '' %>
<%- end -%>
  end
end
